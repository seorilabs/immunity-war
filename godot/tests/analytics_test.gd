extends RefCounted
## 전투 계측 이벤트 검증: 이름·순서·횟수·파라미터.
## 규격 출처: docs/game-design/03-ui-ux-spec.md:137·160, 이슈 #8 인수조건.

const FIXED_DELTA := 1.0 / 30.0
const MAX_STEPS := 20000

## 발화 이벤트를 그대로 기록하는 목 포트.
class MockPort extends AnalyticsPort:
	var events: Array[Dictionary] = []

	func track(event_name: String, params: Dictionary) -> void:
		events.append({"name": event_name, "params": params.duplicate(true)})

	func names() -> Array[String]:
		var result: Array[String] = []
		for event in events:
			result.append(String(event["name"]))
		return result

	func count(event_name: String) -> int:
		var total := 0
		for event in events:
			if event["name"] == event_name:
				total += 1
		return total

	func first(event_name: String) -> Dictionary:
		for event in events:
			if event["name"] == event_name:
				return event["params"]
		return {}

static func run(host: Node) -> PackedStringArray:
	var failures := PackedStringArray()
	_check_win_run(failures, host)
	_check_give_up_run(failures, host)
	_check_default_port_is_noop(failures)
	return failures

static func _check_win_run(failures: PackedStringArray, host: Node) -> void:
	var world := Node2D.new()
	host.add_child(world)
	var controller := _controller(world)
	var port := MockPort.new()
	controller.analytics = port
	controller.start()

	var steps := 0
	while controller.state != BattleController.State.FINISHED and steps < MAX_STEPS:
		controller.step(FIXED_DELTA)
		if controller.state == BattleController.State.CHOOSING_UPGRADE:
			controller.choose_upgrade(0)
		if controller.can_use_skill():
			controller.use_leader_skill()
		steps += 1

	if controller.state != BattleController.State.FINISHED:
		failures.append("계측 검증 준비 실패: 전투가 끝나지 않음 (state=%d)" % controller.state)
		_teardown(host, world)
		return

	var wave_total := controller.stage.waves.size()
	var names := port.names()

	# 순서: level_start 가 맨 앞, level_end 가 맨 뒤
	if names.is_empty() or names[0] != AnalyticsPort.EVENT_LEVEL_START:
		failures.append("첫 이벤트가 level_start 가 아님: %s" % str(names))
	if names.is_empty() or names[names.size() - 1] != AnalyticsPort.EVENT_LEVEL_END:
		failures.append("마지막 이벤트가 level_end 가 아님: %s" % str(names))

	if port.count(AnalyticsPort.EVENT_LEVEL_START) != 1:
		failures.append("level_start 발화 횟수 이상: %d" % port.count(AnalyticsPort.EVENT_LEVEL_START))
	if port.count(AnalyticsPort.EVENT_WAVE_REACHED) != wave_total:
		failures.append("wave_reached 발화 횟수 이상: 기대 %d, 실제 %d" % [wave_total, port.count(AnalyticsPort.EVENT_WAVE_REACHED)])
	if port.count(AnalyticsPort.EVENT_LEVEL_END) != 1:
		failures.append("승리 판에서 level_end 가 %d회 발화" % port.count(AnalyticsPort.EVENT_LEVEL_END))
	if port.count(AnalyticsPort.EVENT_SKILL_USED) < 1:
		failures.append("skill_used 가 한 번도 발화하지 않음")
	if port.count(AnalyticsPort.EVENT_UPGRADE_PICKED) != wave_total - 1:
		failures.append("upgrade_picked 발화 횟수 이상: 기대 %d, 실제 %d" % [wave_total - 1, port.count(AnalyticsPort.EVENT_UPGRADE_PICKED)])

	# 첫 웨이브 누락 없음: wave 파라미터가 1..N 을 모두 덮는다
	var seen_waves: Array[int] = []
	for event in port.events:
		if event["name"] == AnalyticsPort.EVENT_WAVE_REACHED:
			seen_waves.append(int(event["params"][AnalyticsPort.PARAM_WAVE]))
	for wave in range(1, wave_total + 1):
		if not seen_waves.has(wave):
			failures.append("wave_reached 에 웨이브 %d 누락: %s" % [wave, str(seen_waves)])

	_expect_keys(failures, "level_start", port.first(AnalyticsPort.EVENT_LEVEL_START),
		[AnalyticsPort.PARAM_LEADER_ID, AnalyticsPort.PARAM_STAGE_ID])
	_expect_keys(failures, "wave_reached", port.first(AnalyticsPort.EVENT_WAVE_REACHED),
		[AnalyticsPort.PARAM_LEADER_ID, AnalyticsPort.PARAM_WAVE])
	_expect_keys(failures, "skill_used", port.first(AnalyticsPort.EVENT_SKILL_USED),
		[AnalyticsPort.PARAM_LEADER_ID, AnalyticsPort.PARAM_WAVE, AnalyticsPort.PARAM_ELAPSED])
	var end_params := port.first(AnalyticsPort.EVENT_LEVEL_END)
	_expect_keys(failures, "level_end", end_params, [
		AnalyticsPort.PARAM_LEADER_ID, AnalyticsPort.PARAM_SUCCESS, AnalyticsPort.PARAM_REASON,
		AnalyticsPort.PARAM_WAVE, AnalyticsPort.PARAM_DEFEATED, AnalyticsPort.PARAM_BASE_HP,
		AnalyticsPort.PARAM_ELAPSED,
	])
	if not end_params.is_empty() and not bool(end_params[AnalyticsPort.PARAM_SUCCESS]):
		failures.append("승리 판의 level_end success 가 false")

	_teardown(host, world)

static func _check_give_up_run(failures: PackedStringArray, host: Node) -> void:
	var world := Node2D.new()
	host.add_child(world)
	var controller := _controller(world)
	var port := MockPort.new()
	controller.analytics = port
	controller.start()
	for i in range(60):
		controller.step(FIXED_DELTA)

	controller.pause()
	controller.retreat()
	# 재진입 가드: 종료 후 finish/retreat 를 더 불러도 level_end 는 늘지 않는다.
	controller.retreat()
	controller.finish(true, "중복 호출")

	if port.count(AnalyticsPort.EVENT_LEVEL_END) != 1:
		failures.append("포기 판에서 level_end 가 %d회 발화" % port.count(AnalyticsPort.EVENT_LEVEL_END))
	var params := port.first(AnalyticsPort.EVENT_LEVEL_END)
	if params.is_empty():
		failures.append("포기 판에서 level_end 파라미터가 비어 있음")
	else:
		if bool(params[AnalyticsPort.PARAM_SUCCESS]):
			failures.append("포기 판의 level_end success 가 true")
		if String(params[AnalyticsPort.PARAM_REASON]).is_empty():
			failures.append("포기 판의 level_end reason 이 비어 있음")

	_teardown(host, world)

## 기본 포트는 no-op — 네트워크 없이도 예외 없이 동작한다.
static func _check_default_port_is_noop(failures: PackedStringArray) -> void:
	var port := AnalyticsPort.new()
	port.track(AnalyticsPort.EVENT_LEVEL_START, {AnalyticsPort.PARAM_LEADER_ID: "macrophage"})
	if not (port is AnalyticsPort):
		failures.append("기본 포트 타입 이상")

static func _expect_keys(failures: PackedStringArray, label: String, params: Dictionary, keys: Array) -> void:
	if params.is_empty():
		failures.append("%s 이벤트가 발화하지 않음" % label)
		return
	for key: String in keys:
		if not params.has(key):
			failures.append("%s 파라미터 누락: %s (%s)" % [label, key, str(params.keys())])

static func _controller(world: Node2D) -> BattleController:
	var roster: Array[CellDef] = [Db.cell(&"macrophage")]
	for teammate_id in Db.teammate_ids(&"macrophage"):
		roster.append(Db.cell(teammate_id))
	return BattleController.new(Db.stage(&"1-1"), roster, world, Vector2(390.0, 844.0), 12345)

static func _teardown(host: Node, world: Node2D) -> void:
	host.remove_child(world)
	world.queue_free()
