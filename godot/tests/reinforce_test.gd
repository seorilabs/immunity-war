extends RefCounted
## 증원 게이지 검증. 규격 출처: docs/game-design/02-gdd.md:109~110 (CON-003 처치당 8·최대 100, CON-004 지속 15s).

const EPSILON := 0.0001
const FIXED_DELTA := 1.0 / 30.0

static func run(host: Node) -> PackedStringArray:
	var failures := PackedStringArray()
	_check_constants(failures)
	_check_gauge_and_summon(failures, host)
	return failures

static func _check_constants(failures: PackedStringArray) -> void:
	if not is_equal_approx(BattleController.REINFORCE_GAIN_PER_KILL, 8.0):
		failures.append("CON-003 처치당 충전량 불일치: %s" % BattleController.REINFORCE_GAIN_PER_KILL)
	if not is_equal_approx(BattleController.REINFORCE_MAX, 100.0):
		failures.append("CON-003 게이지 상한 불일치: %s" % BattleController.REINFORCE_MAX)
	if not is_equal_approx(BattleController.REINFORCE_DURATION, 15.0):
		failures.append("CON-004 증원 지속 불일치: %s" % BattleController.REINFORCE_DURATION)

static func _check_gauge_and_summon(failures: PackedStringArray, host: Node) -> void:
	var world := Node2D.new()
	host.add_child(world)

	var roster: Array[CellDef] = [Db.cell(&"macrophage")]
	for teammate_id in Db.teammate_ids(&"macrophage"):
		roster.append(Db.cell(teammate_id))
	var controller := BattleController.new(Db.stage(&"1-1"), roster, world, Vector2(390.0, 844.0), 12345)
	controller.start()
	var base_cell_count := controller.registry.cells.size()

	if controller.can_reinforce():
		failures.append("전투 시작 시점에 증원이 가능함 (게이지 %s)" % controller.reinforce_gauge)

	# CON-003 test vector: 13처치 → 104 → 100 클램프, 발동 가능
	var dummy := _dummy_enemy(controller)
	for i in range(12):
		controller.on_enemy_defeated(dummy)
	if not is_equal_approx(controller.reinforce_gauge, 96.0):
		failures.append("12처치 게이지 불일치: 기대 96.0, 실제 %s" % controller.reinforce_gauge)
	if controller.can_reinforce():
		failures.append("12처치(96)에서 증원이 활성화됨")

	controller.on_enemy_defeated(dummy)
	dummy.free()
	if not is_equal_approx(controller.reinforce_gauge, BattleController.REINFORCE_MAX):
		failures.append("13처치 게이지 클램프 실패: 기대 100.0, 실제 %s" % controller.reinforce_gauge)
	if not controller.can_reinforce():
		failures.append("13처치 후에도 증원이 비활성")

	if not controller.call_reinforcement():
		failures.append("증원 발동이 거부됨")
	if not is_equal_approx(controller.reinforce_gauge, 0.0):
		failures.append("증원 발동 후 게이지가 0이 아님: %s" % controller.reinforce_gauge)
	if controller.can_reinforce():
		failures.append("증원 발동 직후에도 재발동 가능")
	if controller.registry.cells.size() != base_cell_count + 1:
		failures.append("임시 세포가 소환되지 않음 (%d → %d)" % [base_cell_count, controller.registry.cells.size()])

	var summoned: CellUnit = controller.registry.cells[controller.registry.cells.size() - 1]
	if summoned.is_leader:
		failures.append("임시 세포가 리더 표식을 가짐: %s" % summoned.def.id)
	if not summoned.is_temporary:
		failures.append("임시 세포가 임시 표시를 갖지 않음: %s" % summoned.def.id)
	if summoned.def.id == roster[0].id:
		failures.append("증원이 리더와 같은 세포로 소환됨: %s" % summoned.def.id)

	# CON-004: 15초 뒤 자연 퇴장 (그 전에는 남아 있어야 한다)
	_advance(controller, BattleController.REINFORCE_DURATION - 1.0)
	if not controller.registry.cells.has(summoned):
		failures.append("증원 세포가 14초 시점에 이미 사라짐")
	_advance(controller, 1.5)
	if controller.registry.cells.has(summoned):
		failures.append("증원 세포가 15초 후에도 남아 있음 (남은 시간 %.2fs)" % summoned.remaining_lifetime)
	if is_instance_valid(summoned) and not summoned.is_queued_for_deletion():
		failures.append("증원 세포 노드가 해제되지 않음")

	# 전투 종료 후에는 증원이 동작하지 않는다
	controller.reinforce_gauge = BattleController.REINFORCE_MAX
	controller.finish(false, "테스트 종료")
	if controller.can_reinforce():
		failures.append("전투 종료 후에도 증원이 활성")
	if controller.call_reinforcement():
		failures.append("전투 종료 후 증원이 발동됨")

	host.remove_child(world)
	world.queue_free()

## 전투가 흐르는 시간만 센다 — 강화 3택으로 멈추면 첫 카드를 골라 이어 간다 (증원 지속도 전투 시간 기준).
## 처치 이벤트만 필요하므로 트리에 붙지 않은 적 노드 1기를 재사용하고 검사 후 즉시 해제한다.
static func _dummy_enemy(controller: BattleController) -> EnemyUnit:
	var enemy := EnemyUnit.new()
	enemy.configure(Db.enemy(&"bacteria_swarm"), controller)
	return enemy

static func _advance(controller: BattleController, seconds: float) -> void:
	var steps := int(round(seconds / FIXED_DELTA))
	for i in range(steps):
		if controller.state == BattleController.State.CHOOSING_UPGRADE:
			controller.choose_upgrade(0)
		controller.step(FIXED_DELTA)
