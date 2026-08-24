class_name BattleController
extends RefCounted
## 전투 상태 머신. UI 노드를 참조하지 않는다 — battle_scene(런타임)과 balance_sim(헤드리스)이 동일하게 구동한다.

signal wave_started(index: int, total: int, wave_name: String)
signal status_changed(text: String)
signal base_changed(hp: float, max_hp: float)
signal fx_requested(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float)
signal battle_finished(summary: Dictionary)

enum State {RUNNING, BETWEEN_WAVES, FINISHED}

const BETWEEN_WAVE_DELAY := 1.4

var stage: StageDef
var roster: Array[CellDef] = []
var world: Node2D
var arena_size := Vector2(390.0, 844.0)
var rng := RandomNumberGenerator.new()
var registry := UnitRegistry.new()
var spawner := WaveSpawner.new()

var leader: CellUnit
var state := State.RUNNING
var base_hp := 120.0
var max_base_hp := 120.0
var elapsed := 0.0
var wave_index := -1
var wave_elapsed := 0.0
var between_timer := 0.0
var defeated_count := 0
var skill_cooldown := 0.0

func _init(new_stage: StageDef, new_roster: Array[CellDef], new_world: Node2D, new_arena_size: Vector2, seed_value: int) -> void:
	stage = new_stage
	roster = new_roster
	world = new_world
	arena_size = new_arena_size
	rng.seed = seed_value

func start() -> void:
	max_base_hp = stage.base_hp
	base_hp = stage.base_hp
	_spawn_cells()
	_start_wave(0)

func step(delta: float) -> void:
	if state == State.FINISHED:
		return

	elapsed += delta
	skill_cooldown = maxf(0.0, skill_cooldown - delta)

	if state == State.RUNNING:
		wave_elapsed += delta
		for event in spawner.pop_due(wave_elapsed):
			_spawn_enemy(event)

	for cell in registry.cells:
		if is_instance_valid(cell):
			cell.step(delta)
	for enemy in registry.enemies:
		if is_instance_valid(enemy) and enemy.alive:
			enemy.step(delta)
	for projectile in registry.projectiles:
		if is_instance_valid(projectile):
			projectile.step(delta)
	registry.prune()

	if state == State.RUNNING:
		if spawner.is_exhausted() and registry.enemies.is_empty():
			if wave_index >= stage.waves.size() - 1:
				finish(true, "방어 성공")
			else:
				state = State.BETWEEN_WAVES
				between_timer = BETWEEN_WAVE_DELAY
				status_changed.emit("다음 침투를 감지 중")
	elif state == State.BETWEEN_WAVES:
		between_timer -= delta
		if between_timer <= 0.0:
			_start_wave(wave_index + 1)

func skill() -> SkillDef:
	return roster[0].skill

func can_use_skill() -> bool:
	return state == State.RUNNING and skill_cooldown <= 0.0 and is_instance_valid(leader)

func use_leader_skill() -> void:
	if not can_use_skill():
		return
	var leader_skill := skill()
	skill_cooldown = leader_skill.cooldown
	status_changed.emit(leader_skill.display_name)
	SkillSystem.execute(leader_skill, self)

func fire_projectile(source: CellUnit, target: EnemyUnit, damage: float, color: Color) -> void:
	if not is_instance_valid(target):
		return
	var projectile := Projectile.new()
	projectile.position = source.position
	projectile.configure(target, damage, color, source.def.id)
	world.add_child(projectile)
	registry.projectiles.append(projectile)

func on_base_reached(enemy: EnemyUnit) -> void:
	request_fx("blast", enemy.position, enemy.def.radius * 2.2, enemy.def.color, 0.35)
	damage_base(enemy.def.base_damage)

func on_enemy_defeated(enemy: EnemyUnit) -> void:
	defeated_count += 1
	request_fx("ring", enemy.position, enemy.def.radius * 2.0, enemy.def.color, 0.34)

func damage_base(amount: float) -> void:
	if state == State.FINISHED:
		return
	base_hp = maxf(0.0, base_hp - amount)
	status_changed.emit("조직 경계 손상 -" + str(int(amount)))
	base_changed.emit(base_hp, max_base_hp)
	if base_hp <= 0.0:
		finish(false, "방어 실패")

func request_fx(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float) -> void:
	fx_requested.emit(kind, world_pos, radius, color, lifetime)

func retreat() -> void:
	finish(false, "철수")

func finish(success: bool, reason: String) -> void:
	if state == State.FINISHED:
		return
	state = State.FINISHED
	var summary := {
		"success": success,
		"reason": reason,
		"leader_id": roster[0].id,
		"leader_name": roster[0].display_name,
		"base_hp": int(round(base_hp)),
		"elapsed": elapsed,
		"wave": wave_index + 1,
		"defeated": defeated_count,
		"learning": roster[0].result_copy,
	}
	battle_finished.emit(summary)

func _start_wave(index: int) -> void:
	wave_index = index
	wave_elapsed = 0.0
	state = State.RUNNING
	var wave: WaveDef = stage.waves[index]
	spawner.load_wave(wave)
	wave_started.emit(index, stage.waves.size(), wave.display_name)
	status_changed.emit(wave.display_name)

func _spawn_cells() -> void:
	for i in range(roster.size()):
		var cell := CellUnit.new()
		cell.configure(roster[i], i == 0, self, ArenaLayout.cell_home(arena_size, i))
		world.add_child(cell)
		registry.cells.append(cell)
	if not registry.cells.is_empty():
		leader = registry.cells[0]

func _spawn_enemy(event: Dictionary) -> void:
	var enemy := EnemyUnit.new()
	enemy.configure(event["enemy"] as EnemyDef, self)
	enemy.position = ArenaLayout.spawn_position(arena_size, int(event["lane"]), rng)
	world.add_child(enemy)
	registry.enemies.append(enemy)
