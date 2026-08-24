extends RefCounted
## 전투 일시정지 검증. 규격 출처: docs/game-design/03-ui-ux-spec.md:34~36·136, docs/game-design/02-gdd.md:49.

const EPSILON := 0.0001
const FIXED_DELTA := 1.0 / 30.0
const IDLE_STEPS := 900  # 30초 방치

static func run(host: Node) -> PackedStringArray:
	var failures := PackedStringArray()
	_check_freeze_and_resume(failures, host)
	_check_guards(failures, host)
	return failures

## 멈춘 시점 그대로 이어지는지 — 웨이브 경과·스폰 커서·쿨다운·유닛 좌표 전부.
static func _check_freeze_and_resume(failures: PackedStringArray, host: Node) -> void:
	var world := Node2D.new()
	host.add_child(world)
	var controller := _controller(world)
	controller.start()

	# 적이 실제로 움직이는 상태까지 진행하고 리더 스킬로 쿨다운도 걸어 둔다.
	for i in range(240):
		controller.step(FIXED_DELTA)
	if controller.can_use_skill():
		controller.use_leader_skill()
	if controller.registry.enemies.is_empty():
		failures.append("일시정지 검증 준비 실패: 적이 없음")

	if not controller.pause():
		failures.append("전투 중 일시정지가 거부됨")
	if not controller.is_paused():
		failures.append("pause() 후 상태가 PAUSED 가 아님 (state=%d)" % controller.state)

	var frozen := _snapshot(controller)
	for i in range(IDLE_STEPS):
		controller.step(FIXED_DELTA)
	var after_idle := _snapshot(controller)
	for key in frozen:
		if typeof(frozen[key]) == TYPE_FLOAT:
			if absf(float(frozen[key]) - float(after_idle[key])) > EPSILON:
				failures.append("일시정지 중 %s 가 변함: %s → %s" % [key, frozen[key], after_idle[key]])
		elif frozen[key] != after_idle[key]:
			failures.append("일시정지 중 %s 가 변함: %s → %s" % [key, str(frozen[key]), str(after_idle[key])])

	if not controller.resume():
		failures.append("일시정지 상태에서 계속하기가 거부됨")
	if controller.state != BattleController.State.RUNNING:
		failures.append("resume() 후 RUNNING 이 아님 (state=%d)" % controller.state)

	var resumed := _snapshot(controller)
	if absf(float(resumed["wave_elapsed"]) - float(frozen["wave_elapsed"])) > EPSILON:
		failures.append("계속하기 직후 웨이브 경과 시간이 유실됨: %s → %s" % [frozen["wave_elapsed"], resumed["wave_elapsed"]])
	if absf(float(resumed["skill_cooldown"]) - float(frozen["skill_cooldown"])) > EPSILON:
		failures.append("계속하기 직후 스킬 쿨다운이 유실됨: %s → %s" % [frozen["skill_cooldown"], resumed["skill_cooldown"]])

	controller.step(FIXED_DELTA)
	if float(_snapshot(controller)["elapsed"]) <= float(frozen["elapsed"]):
		failures.append("계속하기 후에도 전투 시간이 흐르지 않음")

	_teardown(host, world)

static func _check_guards(failures: PackedStringArray, host: Node) -> void:
	var world := Node2D.new()
	host.add_child(world)
	var controller := _controller(world)
	controller.start()

	# 강화 3택 중에는 일시정지 진입 불가 (03-ui-ux-spec.md:35 — 이미 정지 상태)
	var steps := 0
	while controller.state == BattleController.State.RUNNING and steps < 20000:
		controller.step(FIXED_DELTA)
		if controller.can_use_skill():
			controller.use_leader_skill()
		steps += 1
	if controller.state != BattleController.State.CHOOSING_UPGRADE:
		failures.append("가드 검증 준비 실패: CHOOSING_UPGRADE 진입 실패 (state=%d)" % controller.state)
	elif controller.pause():
		failures.append("강화 3택 중에 일시정지가 진입됨")

	controller.choose_upgrade(0)

	# 포기: 일시정지 상태에서 실패로 종료된다
	var summary: Dictionary = {}
	controller.battle_finished.connect(func(result: Dictionary) -> void: summary.merge(result, true))
	if not controller.pause():
		failures.append("포기 검증 준비 실패: 일시정지 진입 실패")
	controller.retreat()
	if controller.state != BattleController.State.FINISHED:
		failures.append("포기 후 상태가 FINISHED 가 아님 (state=%d)" % controller.state)
	if summary.is_empty():
		failures.append("포기 후 결과 요약이 방출되지 않음")
	elif bool(summary["success"]):
		failures.append("포기가 실패 처리되지 않음: success=%s" % str(summary["success"]))

	# 종료 후에는 일시정지·계속하기가 전투를 되살리지 않는다
	if controller.pause():
		failures.append("전투 종료 후 일시정지가 진입됨")
	if controller.resume():
		failures.append("전투 종료 후 계속하기가 동작함")
	if controller.state != BattleController.State.FINISHED:
		failures.append("전투 종료 후 상태가 되살아남 (state=%d)" % controller.state)

	_teardown(host, world)

static func _controller(world: Node2D) -> BattleController:
	var roster: Array[CellDef] = [Db.cell(&"macrophage")]
	for teammate_id in Db.teammate_ids(&"macrophage"):
		roster.append(Db.cell(teammate_id))
	return BattleController.new(Db.stage(&"1-1"), roster, world, Vector2(390.0, 844.0), 12345)

static func _snapshot(controller: BattleController) -> Dictionary:
	var positions := PackedVector2Array()
	for enemy in controller.registry.enemies:
		positions.append(enemy.position)
	var cell_positions := PackedVector2Array()
	for cell in controller.registry.cells:
		cell_positions.append(cell.position)
	return {
		"elapsed": controller.elapsed,
		"wave_elapsed": controller.wave_elapsed,
		"wave_index": controller.wave_index,
		"skill_cooldown": controller.skill_cooldown,
		"base_hp": controller.base_hp,
		"enemy_count": controller.registry.enemies.size(),
		"enemy_positions": positions,
		"cell_positions": cell_positions,
		"projectile_count": controller.registry.projectiles.size(),
	}

static func _teardown(host: Node, world: Node2D) -> void:
	host.remove_child(world)
	world.queue_free()
