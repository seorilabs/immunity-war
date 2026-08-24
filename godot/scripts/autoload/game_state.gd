extends Node
## 메타 진행(재화·해금·레벨·스테이지)과 런 스냅숏의 진입점. 저장은 SaveService에 위임한다.

signal currency_changed(balance: int)

var last_summary: Dictionary = {}
## 직전 전투의 보상 내역 (result 화면 표시용): {earned, first_clear, balance}
var last_rewards: Dictionary = {}

func currency() -> int:
	return int(SaveService.meta().get("currency", 0))

func add_currency(amount: int) -> void:
	SaveService.meta()["currency"] = currency() + amount
	SaveService.mark_dirty()
	currency_changed.emit(currency())

func try_spend(amount: int) -> bool:
	if currency() < amount:
		return false
	SaveService.meta()["currency"] = currency() - amount
	SaveService.mark_dirty()
	currency_changed.emit(currency())
	return true

func cell_state(cell_id: StringName) -> Dictionary:
	var cells: Dictionary = SaveService.meta().get("cells", {})
	return cells.get(String(cell_id), {"unlocked": false, "level": 1})

func is_unlocked(cell_id: StringName) -> bool:
	return bool(cell_state(cell_id).get("unlocked", false))

func cell_level(cell_id: StringName) -> int:
	return int(cell_state(cell_id).get("level", 1))

func unlocked_cell_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in Db.cell_order:
		if is_unlocked(id):
			ids.append(id)
	return ids

func try_level_up(cell_id: StringName) -> bool:
	var level := cell_level(cell_id)
	if level >= Economy.LEVEL_MAX or not is_unlocked(cell_id):
		return false
	if not try_spend(Economy.level_up_cost(level)):
		return false
	SaveService.meta()["cells"][String(cell_id)]["level"] = level + 1
	SaveService.mark_dirty()
	return true

func is_stage_cleared(stage_id: StringName) -> bool:
	var stage_records: Dictionary = SaveService.meta().get("stages", {})
	return bool(stage_records.get(String(stage_id), {}).get("cleared", false))

## 순차 진행에서 다음 도전 스테이지 (전부 클리어면 마지막 스테이지).
func next_stage() -> StageDef:
	var sequence := Db.stage_sequence()
	for stage_def in sequence:
		if not is_stage_cleared(stage_def.id):
			return stage_def
	return sequence.back()

func is_stage_unlocked(stage_def: StageDef) -> bool:
	return stage_def.order <= next_stage().order

## 덱: 리더 1 + 동료 최대 3. 보유 세포가 4 이하인 동안 동료는 자동 편성된다.
func deck_leader() -> StringName:
	var deck: Dictionary = SaveService.meta().get("last_deck", {})
	var leader := StringName(str(deck.get("leader", "macrophage")))
	if not is_unlocked(leader):
		leader = &"macrophage"
	return leader

func set_deck_leader(cell_id: StringName) -> void:
	if not is_unlocked(cell_id):
		return
	SaveService.meta()["last_deck"]["leader"] = String(cell_id)
	SaveService.mark_dirty()

func deck_members(leader_id: StringName) -> Array[StringName]:
	var members: Array[StringName] = []
	for id in unlocked_cell_ids():
		if id != leader_id and members.size() < 3:
			members.append(id)
	return members

## 전투 진입 계약 조립. restore=true면 저장된 run 스냅숏에서 이어한다.
func build_battle_config(stage_id: StringName, arena_size: Vector2, restore: bool = false) -> BattleConfig:
	var config := BattleConfig.new()
	config.stage = Db.stage(stage_id)
	config.arena_size = arena_size

	var leader_id := deck_leader()
	var run: Variant = SaveService.data.get("run")
	if restore and run is Dictionary:
		var run_dict: Dictionary = run
		leader_id = StringName(str(run_dict.get("leader", leader_id)))
		config.start_wave_index = int(run_dict.get("wave_index", 0))
		config.start_base_hp = float(run_dict.get("base_hp", -1.0))
		config.reinforce_gauge = float(run_dict.get("reinforce_gauge", 0.0))
		config.rng_seed = int(run_dict.get("rng_seed", randi()))
		for upgrade_id: Variant in run_dict.get("upgrades", []):
			config.upgrade_ids.append(StringName(str(upgrade_id)))
	else:
		config.rng_seed = randi()

	config.roster = [Db.cell(leader_id)]
	for member_id in deck_members(leader_id):
		config.roster.append(Db.cell(member_id))
	for id in unlocked_cell_ids():
		if id != leader_id and not deck_members(leader_id).has(id):
			config.reserve_cells.append(Db.cell(id))
	for cell_def in config.roster:
		config.levels[cell_def.id] = cell_level(cell_def.id)
	return config

func has_run() -> bool:
	return SaveService.data.get("run") is Dictionary

func run_stage_id() -> StringName:
	var run: Variant = SaveService.data.get("run")
	if run is Dictionary:
		return StringName(str((run as Dictionary).get("stage_id", "")))
	return &""

func save_run(snapshot: Dictionary) -> void:
	SaveService.data["run"] = snapshot
	SaveService.mark_dirty()

func clear_run() -> void:
	SaveService.data["run"] = null
	SaveService.mark_dirty()

## 전투 종료 처리: 메타 반영 + 보상 계산. result 화면이 last_rewards를 읽는다.
func on_battle_finished(summary: Dictionary) -> void:
	last_summary = summary
	last_rewards = {}
	clear_run()

	var stage_def := Db.stage(StringName(str(summary.get("stage_id", ""))))
	if stage_def == null or not bool(summary.get("success", false)):
		SaveService.flush_now()
		return

	var first := not is_stage_cleared(stage_def.id)
	var earned := Economy.reward_first(stage_def.order, stage_def.is_boss) if first else Economy.reward_base(stage_def.order)
	var stage_records: Dictionary = SaveService.meta()["stages"]
	var record: Dictionary = stage_records.get(String(stage_def.id), {})
	record["cleared"] = true
	record["best_wave"] = maxi(int(record.get("best_wave", 0)), int(summary.get("wave", 0)))
	stage_records[String(stage_def.id)] = record
	add_currency(earned)
	last_rewards = {"earned": earned, "first_clear": first, "balance": currency()}
	SaveService.mark_dirty()
	SaveService.flush_now()

func mark_tutorial_done() -> void:
	SaveService.flags()["tutorial_done"] = true
	SaveService.mark_dirty()

func is_tutorial_done() -> bool:
	return bool(SaveService.flags().get("tutorial_done", false))
