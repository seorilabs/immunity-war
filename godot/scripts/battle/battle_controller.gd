class_name BattleController
extends RefCounted
## 전투 상태 머신. UI 노드를 참조하지 않는다 — battle_scene(런타임)과 balance_sim(헤드리스)이 동일하게 구동한다.
## 상태 흐름: RUNNING → BETWEEN_WAVES → CHOOSING_UPGRADE → RUNNING → ... → FINISHED (02-gdd 전투 상태 머신)

signal wave_started(index: int, total: int, wave_name: String)
signal status_changed(text: String)
signal base_changed(hp: float, max_hp: float, shield: float)
signal reinforce_changed(gauge: float, ready: bool)
signal upgrade_offered(options: Array[UpgradeDef])
signal run_snapshot(snapshot: Dictionary)
signal fx_requested(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float)
signal battle_finished(summary: Dictionary)

enum State {RUNNING, BETWEEN_WAVES, CHOOSING_UPGRADE, FINISHED}

const BETWEEN_WAVE_DELAY := 1.0
const REINFORCE_PER_KILL := 8.0
const REINFORCE_MAX := 100.0
const REINFORCE_DURATION := 15.0
const REINFORCE_BASE_HEAL := 15.0
const SLOW_AURA_RANGE := 180.0
const UPGRADE_CHOICES := 3

var config: BattleConfig
var world: Node2D
var arena_size := Vector2(390.0, 844.0)
var rng := RandomNumberGenerator.new()
var registry := UnitRegistry.new()
var spawner := WaveSpawner.new()
var run := RunModifiers.new()

var leader: CellUnit
var state := State.RUNNING
var base_hp := 120.0
var max_base_hp := 120.0
var base_shield := 0.0
var reinforce_gauge := 0.0
var elapsed := 0.0
var wave_index := -1
var wave_elapsed := 0.0
var between_timer := 0.0
var defeated_count := 0
var skill_cooldown := 0.0
var pending_options: Array[UpgradeDef] = []

func _init(new_config: BattleConfig, new_world: Node2D) -> void:
	config = new_config
	world = new_world
	arena_size = new_config.arena_size
	rng.seed = new_config.rng_seed

func stage() -> StageDef:
	return config.stage

func start() -> void:
	max_base_hp = config.stage.base_hp
	base_hp = config.start_base_hp if config.start_base_hp >= 0.0 else max_base_hp
	reinforce_gauge = config.reinforce_gauge
	for upgrade_id in config.upgrade_ids:
		var upgrade := Db.upgrade(upgrade_id)
		if upgrade != null:
			run.apply(upgrade)
	_spawn_cells()
	_start_wave(config.start_wave_index)

func step(delta: float) -> void:
	if state == State.FINISHED or state == State.CHOOSING_UPGRADE:
		return

	elapsed += delta
	skill_cooldown = maxf(0.0, skill_cooldown - delta)

	if state == State.RUNNING:
		wave_elapsed += delta
		for event in spawner.pop_due(wave_elapsed):
			_spawn_enemy(event)

	for cell in registry.cells:
		if is_instance_valid(cell) and cell.active:
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
			if wave_index >= config.stage.waves.size() - 1:
				finish(true, "방어 성공")
			else:
				state = State.BETWEEN_WAVES
				between_timer = BETWEEN_WAVE_DELAY
				status_changed.emit("다음 침투를 감지 중")
	elif state == State.BETWEEN_WAVES:
		between_timer -= delta
		if between_timer <= 0.0:
			_offer_upgrades()

func skill() -> SkillDef:
	return config.roster[0].skill

func skill_max_cooldown() -> float:
	return skill().cooldown * run.skill_cd_mult

func can_use_skill() -> bool:
	return state == State.RUNNING and skill_cooldown <= 0.0 and is_instance_valid(leader)

func use_leader_skill() -> void:
	if not can_use_skill():
		return
	skill_cooldown = skill_max_cooldown()
	status_changed.emit(skill().display_name)
	SkillSystem.execute(skill(), self)

func can_use_reinforcement() -> bool:
	return state == State.RUNNING and reinforce_gauge >= REINFORCE_MAX

func use_reinforcement() -> void:
	if not can_use_reinforcement():
		return
	reinforce_gauge = 0.0
	var reserve := config_reserve()
	if reserve.is_empty():
		base_hp = minf(max_base_hp, base_hp + REINFORCE_BASE_HEAL)
		status_changed.emit("조직 재생 +%d" % int(REINFORCE_BASE_HEAL))
		base_changed.emit(base_hp, max_base_hp, base_shield)
	else:
		var def: CellDef = reserve[rng.randi_range(0, reserve.size() - 1)]
		var cell := CellUnit.new()
		cell.configure(def, false, self, ArenaLayout.cell_home(arena_size, registry.cells.size() % 3))
		cell.level = config.cell_level(def.id)
		cell.expire_timer = REINFORCE_DURATION
		world.add_child(cell)
		registry.cells.append(cell)
		status_changed.emit("증원 도착: " + def.display_name)
		request_fx("ring", cell.position, 60.0, def.accent, 0.6)
	reinforce_changed.emit(reinforce_gauge, false)

func config_reserve() -> Array[CellDef]:
	return config.reserve_cells

func apply_upgrade(option_index: int) -> void:
	if state != State.CHOOSING_UPGRADE or option_index < 0 or option_index >= pending_options.size():
		return
	var picked := pending_options[option_index]
	run.apply(picked)
	pending_options = []
	status_changed.emit(picked.display_name)
	_start_wave(wave_index + 1)

## 세포의 발사 1회 피해 (레벨·런 강화 반영).
func cell_damage(def: CellDef, level: int) -> float:
	return def.damage * CombatRules.level_mult(level) * run.damage_multiplier(def.tags)

func cell_attack_interval(def: CellDef) -> float:
	return def.attack_rate * run.attack_interval_mult

## 적 이속 배율 (슬로우 오라).
func enemy_speed_mult(enemy_x: float) -> float:
	if run.slow_aura_factor > 0.0 and enemy_x <= ArenaLayout.BASE_X + SLOW_AURA_RANGE:
		return 1.0 - run.slow_aura_factor
	return 1.0

func mark_mult() -> float:
	return CombatRules.MARK_MULT + run.mark_bonus

func roll_crit() -> bool:
	return run.crit_chance > 0.0 and rng.randf() < run.crit_chance

func fire_projectile(source: CellUnit, target: EnemyUnit, damage: float, color: Color) -> void:
	if not is_instance_valid(target):
		return
	var projectile := Projectile.new()
	projectile.position = source.position
	projectile.configure(target, damage, color, source.def.tags)
	world.add_child(projectile)
	registry.projectiles.append(projectile)

func on_base_reached(enemy: EnemyUnit) -> void:
	request_fx("blast", enemy.position, enemy.def.radius * 2.2, enemy.def.color, 0.35)
	damage_base(enemy.def.base_damage)

func on_enemy_defeated(enemy: EnemyUnit) -> void:
	defeated_count += 1
	reinforce_gauge = minf(REINFORCE_MAX, reinforce_gauge + REINFORCE_PER_KILL * run.reinforce_charge_mult)
	reinforce_changed.emit(reinforce_gauge, can_use_reinforcement())
	request_fx("ring", enemy.position, enemy.def.radius * 2.0, enemy.def.color, 0.34)

func damage_base(amount: float) -> void:
	if state == State.FINISHED:
		return
	var remaining := amount
	if base_shield > 0.0:
		var absorbed := minf(base_shield, remaining)
		base_shield -= absorbed
		remaining -= absorbed
	if remaining > 0.0:
		base_hp = maxf(0.0, base_hp - remaining)
		status_changed.emit("조직 경계 손상 -" + str(int(remaining)))
	base_changed.emit(base_hp, max_base_hp, base_shield)
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
		"stage_id": String(config.stage.id),
		"leader_id": String(config.roster[0].id),
		"leader_name": config.roster[0].display_name,
		"base_hp": int(round(base_hp)),
		"elapsed": elapsed,
		"wave": wave_index + 1,
		"defeated": defeated_count,
		"upgrades": run.upgrade_ids.duplicate(),
		"learning": config.roster[0].result_copy,
	}
	battle_finished.emit(summary)

func _offer_upgrades() -> void:
	state = State.CHOOSING_UPGRADE
	pending_options = _draw_upgrades()
	if pending_options.is_empty():
		_start_wave(wave_index + 1)
		return
	upgrade_offered.emit(pending_options)

func _draw_upgrades() -> Array[UpgradeDef]:
	var pool: Array[UpgradeDef] = []
	var weights: Array[float] = []
	for upgrade: UpgradeDef in Db.upgrade_list:
		pool.append(upgrade)
		weights.append(3.0 if upgrade.rarity == UpgradeDef.Rarity.COMMON else 1.0)
	var options: Array[UpgradeDef] = []
	while options.size() < UPGRADE_CHOICES and not pool.is_empty():
		var total := 0.0
		for weight in weights:
			total += weight
		var roll := rng.randf() * total
		var acc := 0.0
		var picked_index := pool.size() - 1
		for i in range(pool.size()):
			acc += weights[i]
			if roll <= acc:
				picked_index = i
				break
		options.append(pool[picked_index])
		pool.remove_at(picked_index)
		weights.remove_at(picked_index)
	return options

func _start_wave(index: int) -> void:
	wave_index = index
	wave_elapsed = 0.0
	state = State.RUNNING
	if run.base_regen > 0.0 and index > config.start_wave_index:
		base_hp = minf(max_base_hp, base_hp + run.base_regen)
	base_shield = run.wave_shield
	base_changed.emit(base_hp, max_base_hp, base_shield)
	var wave: WaveDef = config.stage.waves[index]
	spawner.load_wave(wave)
	wave_started.emit(index, config.stage.waves.size(), wave.display_name)
	status_changed.emit(wave.display_name)
	run_snapshot.emit({
		"stage_id": String(config.stage.id),
		"wave_index": index,
		"base_hp": base_hp,
		"reinforce_gauge": reinforce_gauge,
		"upgrades": run.upgrade_ids.map(func(id: StringName) -> String: return String(id)),
		"rng_seed": int(config.rng_seed),
		"leader": String(config.roster[0].id),
	})

func _spawn_cells() -> void:
	for i in range(config.roster.size()):
		var cell := CellUnit.new()
		cell.configure(config.roster[i], i == 0, self, ArenaLayout.cell_home(arena_size, i))
		cell.level = config.cell_level(config.roster[i].id)
		world.add_child(cell)
		registry.cells.append(cell)
	if not registry.cells.is_empty():
		leader = registry.cells[0]

func _spawn_enemy(event: Dictionary) -> void:
	var enemy := EnemyUnit.new()
	enemy.configure(event["enemy"] as EnemyDef, self, config.stage.hp_mult)
	enemy.position = ArenaLayout.spawn_position(arena_size, int(event["lane"]), rng)
	world.add_child(enemy)
	registry.enemies.append(enemy)
