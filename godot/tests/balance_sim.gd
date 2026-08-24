extends Node
## 헤드리스 밸런스 시뮬: 챕터1 전 스테이지를 코호트(세포 레벨 1 / 5)별로 고정 시드·고정 델타로 완주.
## 정책: 스킬·증원은 준비 즉시 사용, 강화 3택은 첫 번째 선택.
## 설계 목표 (02-gdd 진행 표): lv1은 order 1~3 클리어 필수, lv5는 전 스테이지 클리어 필수.

const FIXED_DELTA := 1.0 / 30.0
const MAX_STEPS := 60000
const SEED_VALUE := 12345

var _summary: Dictionary = {}
var _controller: BattleController

func _ready() -> void:
	var failures := 0
	for cohort_level in [1, 5]:
		for stage_def in Db.stage_sequence():
			var result := _run_battle(stage_def, cohort_level)
			if result.is_empty():
				push_error("balance_sim: lv%d %s 전투가 %d스텝 안에 종료되지 않음" % [cohort_level, stage_def.id, MAX_STEPS])
				failures += 1
				continue
			var success := bool(result["success"])
			print("balance_sim: lv=%d stage=%s success=%s wave=%s base_hp=%s defeated=%s elapsed=%.1fs" % [
				cohort_level, stage_def.id, str(success), str(result["wave"]),
				str(result["base_hp"]), str(result["defeated"]), float(result["elapsed"]),
			])
			if cohort_level == 1 and stage_def.order <= 3 and not success:
				push_error("balance_sim: lv1 코호트가 %s 클리어 실패 (설계 목표 위반)" % stage_def.id)
				failures += 1
			if cohort_level == 5 and not success:
				push_error("balance_sim: lv5 코호트가 %s 클리어 실패 (설계 목표 위반)" % stage_def.id)
				failures += 1
	get_tree().quit(1 if failures > 0 else 0)

func _run_battle(stage_def: StageDef, cohort_level: int) -> Dictionary:
	_summary = {}
	var world := Node2D.new()
	add_child(world)

	var config := BattleConfig.new()
	config.stage = stage_def
	config.rng_seed = SEED_VALUE
	config.roster = [Db.cell(&"macrophage")]
	for teammate_id in Db.teammate_ids(&"macrophage"):
		config.roster.append(Db.cell(teammate_id))
	for cell_def in config.roster:
		config.levels[cell_def.id] = cohort_level

	_controller = BattleController.new(config, world)
	_controller.battle_finished.connect(_capture)
	_controller.upgrade_offered.connect(_auto_pick)
	_controller.start()

	var steps := 0
	while _summary.is_empty() and steps < MAX_STEPS:
		_controller.step(FIXED_DELTA)
		if _controller.can_use_skill():
			_controller.use_leader_skill()
		if _controller.can_use_reinforcement():
			_controller.use_reinforcement()
		steps += 1

	remove_child(world)
	world.queue_free()
	return _summary

func _capture(summary: Dictionary) -> void:
	_summary = summary

func _auto_pick(_options: Array[UpgradeDef]) -> void:
	_controller.apply_upgrade(0)
