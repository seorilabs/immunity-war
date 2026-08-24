class_name BattleController
extends RefCounted
## 전투 상태 머신. UI 노드를 참조하지 않는다 — battle_scene(런타임)과 balance_sim(헤드리스)이 동일하게 구동한다.

signal wave_started(index: int, total: int, wave_name: String)
signal status_changed(text: String)
signal base_changed(hp: float, max_hp: float)
signal fx_requested(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float)
signal battle_finished(summary: Dictionary)
signal upgrade_offered(choices: Array[UpgradeDef])
signal upgrade_chosen(upgrade: UpgradeDef)
signal reinforcement_called(cell_def: CellDef)
signal paused_changed(paused: bool)

enum State {RUNNING, PAUSED, CHOOSING_UPGRADE, FINISHED}

## CON-003 증원 게이지: 처치당 8, 최대 100. CON-004 증원 지속: 15s.
const REINFORCE_GAIN_PER_KILL := 8.0
const REINFORCE_MAX := 100.0
const REINFORCE_DURATION := 15.0

var stage: StageDef
var roster: Array[CellDef] = []
var world: Node2D
var arena_size := Vector2(390.0, 844.0)
var battle_seed := 0
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
var defeated_count := 0
var skill_cooldown := 0.0
var reinforce_gauge := 0.0
var reinforce_count := 0
var run_upgrades := RunUpgrades.new()
## 계측 포트. 기본은 no-op 이며 테스트·후속 GA4 어댑터가 주입으로 교체한다.
var analytics := AnalyticsPort.new()
var upgrade_choices: Array[UpgradeDef] = []

func _init(new_stage: StageDef, new_roster: Array[CellDef], new_world: Node2D, new_arena_size: Vector2, seed_value: int) -> void:
	stage = new_stage
	roster = new_roster
	world = new_world
	arena_size = new_arena_size
	battle_seed = seed_value
	rng.seed = seed_value

func start() -> void:
	max_base_hp = stage.base_hp
	base_hp = stage.base_hp
	analytics.track(AnalyticsPort.EVENT_LEVEL_START, {
		AnalyticsPort.PARAM_LEADER_ID: String(roster[0].id),
		AnalyticsPort.PARAM_STAGE_ID: String(stage.id),
	})
	_spawn_cells()
	_start_wave(0)

## CHOOSING_UPGRADE 동안에는 스폰·유닛·타이머가 전부 멈춘다 (GDD 02-gdd.md:51 "선택 전 대기").
func step(delta: float) -> void:
	if state != State.RUNNING:
		return

	elapsed += delta
	skill_cooldown = maxf(0.0, skill_cooldown - delta)

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

	if spawner.is_exhausted() and registry.enemies.is_empty():
		if wave_index >= stage.waves.size() - 1:
			finish(true, "방어 성공")
		else:
			_offer_upgrades()

## 전투를 얼린다. 강화 3택 중(이미 정지)이나 종료 후에는 진입하지 않는다 (03-ui-ux-spec.md:35).
func pause() -> bool:
	if state != State.RUNNING:
		return false
	state = State.PAUSED
	status_changed.emit("일시정지")
	paused_changed.emit(true)
	return true

## 멈춘 시점 그대로 이어 간다 — 웨이브 경과·스폰 커서·쿨다운은 pause 중 아무것도 건드리지 않는다.
func resume() -> bool:
	if state != State.PAUSED:
		return false
	state = State.RUNNING
	status_changed.emit(stage.waves[wave_index].display_name)
	paused_changed.emit(false)
	return true

func is_paused() -> bool:
	return state == State.PAUSED

func skill() -> SkillDef:
	return roster[0].skill

func can_use_skill() -> bool:
	return state == State.RUNNING and skill_cooldown <= 0.0 and is_instance_valid(leader)

func use_leader_skill() -> void:
	if not can_use_skill():
		return
	var leader_skill := skill()
	skill_cooldown = leader_skill.cooldown * run_upgrades.skill_cooldown_mult
	analytics.track(AnalyticsPort.EVENT_SKILL_USED, {
		AnalyticsPort.PARAM_LEADER_ID: String(roster[0].id),
		AnalyticsPort.PARAM_WAVE: wave_index + 1,
		AnalyticsPort.PARAM_ELAPSED: elapsed,
	})
	status_changed.emit(leader_skill.display_name)
	SkillSystem.execute(leader_skill, self)

func can_reinforce() -> bool:
	return state == State.RUNNING and reinforce_gauge >= REINFORCE_MAX

## 게이지를 소모하고 임시 세포 1기를 투입한다 (CON-004: 15초 후 자연 퇴장).
func call_reinforcement() -> bool:
	if not can_reinforce():
		return false
	var cell_def := _reinforcement_def()
	if cell_def == null:
		return false
	reinforce_gauge = 0.0
	reinforce_count += 1

	var cell := CellUnit.new()
	# 기존 진영 슬롯을 순환하되 살짝 뒤로 물려 배치가 완전히 겹치지 않게 한다.
	var slot := (roster.size() + reinforce_count) % 3
	var home := ArenaLayout.cell_home(arena_size, slot) - Vector2(16.0, 0.0)
	cell.configure(cell_def, false, self, ArenaLayout.clamp_to_arena(arena_size, home))
	cell.make_temporary(REINFORCE_DURATION)
	world.add_child(cell)
	registry.cells.append(cell)

	analytics.track(AnalyticsPort.EVENT_REINFORCE_USED, {
		AnalyticsPort.PARAM_LEADER_ID: String(roster[0].id),
		AnalyticsPort.PARAM_CELL_ID: String(cell_def.id),
		AnalyticsPort.PARAM_WAVE: wave_index + 1,
		AnalyticsPort.PARAM_ELAPSED: elapsed,
	})
	status_changed.emit("증원 도착: " + cell_def.display_name)
	request_fx("ring", cell.position, 46.0, cell_def.accent, 0.5)
	reinforcement_called.emit(cell_def)
	return true

func on_reinforcement_expired(cell: CellUnit) -> void:
	request_fx("ring", cell.position, 38.0, cell.def.color, 0.4)

## 리더가 아닌 세포 중에서 순환 선택한다 (시드 고정 시 결정론).
func _reinforcement_def() -> CellDef:
	var candidates: Array[CellDef] = []
	for cell_def in roster:
		if cell_def != null and cell_def.id != roster[0].id:
			candidates.append(cell_def)
	if candidates.is_empty():
		return null
	return candidates[(reinforce_count) % candidates.size()]

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
	reinforce_gauge = minf(REINFORCE_MAX, reinforce_gauge + REINFORCE_GAIN_PER_KILL)
	heal_base(run_upgrades.on_kill_heal)

func damage_base(amount: float) -> void:
	if state == State.FINISHED:
		return
	base_hp = maxf(0.0, base_hp - amount)
	status_changed.emit("조직 경계 손상 -" + str(int(amount)))
	base_changed.emit(base_hp, max_base_hp)
	if base_hp <= 0.0:
		finish(false, "방어 실패")

func heal_base(amount: float) -> void:
	if amount <= 0.0 or state == State.FINISHED:
		return
	base_hp = minf(max_base_hp, base_hp + amount)
	base_changed.emit(base_hp, max_base_hp)

func request_fx(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float) -> void:
	fx_requested.emit(kind, world_pos, radius, color, lifetime)

## 일시정지 오버레이의 "포기" — 실패로 기록하고 결과 화면으로 보낸다.
func retreat() -> void:
	finish(false, "포기")

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
	analytics.track(AnalyticsPort.EVENT_LEVEL_END, {
		AnalyticsPort.PARAM_LEADER_ID: String(roster[0].id),
		AnalyticsPort.PARAM_STAGE_ID: String(stage.id),
		AnalyticsPort.PARAM_SUCCESS: success,
		AnalyticsPort.PARAM_REASON: reason,
		AnalyticsPort.PARAM_WAVE: wave_index + 1,
		AnalyticsPort.PARAM_DEFEATED: defeated_count,
		AnalyticsPort.PARAM_BASE_HP: int(round(base_hp)),
		AnalyticsPort.PARAM_ELAPSED: elapsed,
	})
	battle_finished.emit(summary)

## 웨이브 사이 강화 3택. 후보는 (전투 시드, 다음 웨이브 인덱스, 보유 강화)로 결정되므로 재표시해도 같다.
func _offer_upgrades() -> void:
	upgrade_choices = UpgradePool.draw(wave_index + 1, battle_seed, run_upgrades.taken)
	if upgrade_choices.is_empty():
		_start_wave(wave_index + 1)
		return
	state = State.CHOOSING_UPGRADE
	status_changed.emit("강화를 선택하세요")
	upgrade_offered.emit(upgrade_choices)

## 3택 중 하나를 확정하고 다음 웨이브를 시작한다. 선택 전에는 어떤 경로로도 웨이브가 진행되지 않는다.
func choose_upgrade(index: int) -> bool:
	if state != State.CHOOSING_UPGRADE:
		return false
	if index < 0 or index >= upgrade_choices.size():
		return false
	var picked := upgrade_choices[index]
	run_upgrades.apply(picked)
	upgrade_choices = []
	analytics.track(AnalyticsPort.EVENT_UPGRADE_PICKED, {
		AnalyticsPort.PARAM_UPGRADE_ID: String(picked.id),
		AnalyticsPort.PARAM_LEADER_ID: String(roster[0].id),
		AnalyticsPort.PARAM_WAVE: wave_index + 1,
	})
	upgrade_chosen.emit(picked)
	_start_wave(wave_index + 1)
	return true

func _start_wave(index: int) -> void:
	wave_index = index
	wave_elapsed = 0.0
	state = State.RUNNING
	heal_base(run_upgrades.base_regen_per_wave)
	var wave: WaveDef = stage.waves[index]
	spawner.load_wave(wave)
	analytics.track(AnalyticsPort.EVENT_WAVE_REACHED, {
		AnalyticsPort.PARAM_LEADER_ID: String(roster[0].id),
		AnalyticsPort.PARAM_WAVE: index + 1,
	})
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
