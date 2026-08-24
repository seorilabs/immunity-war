extends Node
## 헤드리스 밸런스 시뮬: 리더 3종 각각 스테이지 1-1을 고정 시드·고정 델타로 완주시킨다.
## 스킬은 쿨다운이 돌 때마다 즉시 사용하는 그리디 정책, 강화 3택은 항상 첫 카드를 고르는 고정 정책.

const FIXED_DELTA := 1.0 / 30.0
const MAX_STEPS := 40000
const SEED_VALUE := 12345

var _summary: Dictionary = {}

func _ready() -> void:
	var failures := 0
	for leader_id in Db.cell_order:
		var result := _run_battle(leader_id)
		if result.is_empty():
			push_error("balance_sim: %s 전투가 %d스텝 안에 종료되지 않음" % [leader_id, MAX_STEPS])
			failures += 1
			continue
		print("balance_sim: leader=%s success=%s wave=%s base_hp=%s defeated=%s elapsed=%.1fs" % [
			leader_id, str(result["success"]), str(result["wave"]),
			str(result["base_hp"]), str(result["defeated"]), float(result["elapsed"]),
		])
		if not bool(result["success"]):
			push_error("balance_sim: %s 리더가 스테이지 1-1 방어에 실패 (동등성 회귀 의심)" % leader_id)
			failures += 1
	get_tree().quit(1 if failures > 0 else 0)

func _run_battle(leader_id: StringName) -> Dictionary:
	_summary = {}
	var world := Node2D.new()
	add_child(world)

	var roster: Array[CellDef] = [Db.cell(leader_id)]
	for teammate_id in Db.teammate_ids(leader_id):
		roster.append(Db.cell(teammate_id))

	var controller := BattleController.new(Db.stage(&"1-1"), roster, world, Vector2(390.0, 844.0), SEED_VALUE)
	controller.battle_finished.connect(_capture)
	controller.start()

	var steps := 0
	while _summary.is_empty() and steps < MAX_STEPS:
		controller.step(FIXED_DELTA)
		if controller.state == BattleController.State.CHOOSING_UPGRADE:
			controller.choose_upgrade(0)
		if controller.can_use_skill():
			controller.use_leader_skill()
		steps += 1

	remove_child(world)
	world.queue_free()
	return _summary

func _capture(summary: Dictionary) -> void:
	_summary = summary
