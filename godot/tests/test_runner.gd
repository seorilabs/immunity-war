extends Node
## 헤드리스 스모크: main_scene 존재, Db 무결성, SaveService 라운드트립·손상 폴백.

const SaveServiceScript := preload("res://scripts/autoload/save_service.gd")

var _failures: PackedStringArray = []

func _ready() -> void:
	_check_main_scene()
	_check_db()
	_check_economy_vectors()
	_check_battle_config_restore()
	await _check_save_roundtrip()
	await _check_save_corruption_fallback()

	if _failures.is_empty():
		print("smoke: all checks passed")
		get_tree().quit(0)
		return
	for failure in _failures:
		push_error("smoke: " + failure)
	get_tree().quit(1)

func _fail(message: String) -> void:
	_failures.append(message)

func _check_main_scene() -> void:
	var main_scene: String = str(ProjectSettings.get_setting("application/run/main_scene", ""))
	if main_scene.is_empty():
		_fail("application/run/main_scene 미설정")
	elif not ResourceLoader.exists(main_scene):
		_fail("main_scene 리소스 없음: %s" % main_scene)

func _check_db() -> void:
	var errors := Db.validate_and_index()
	for message in errors:
		_fail("Db 무결성: " + message)
	if Db.cells.size() < 3:
		_fail("Db 세포 수 부족: %d" % Db.cells.size())
	if Db.stages.size() < 7:
		_fail("Db 스테이지 수 부족: %d" % Db.stages.size())
	if Db.upgrade_list.size() < 11:
		_fail("Db 강화 수 부족: %d" % Db.upgrade_list.size())
	if Db.chapter_list.is_empty():
		_fail("챕터 정의 누락")
	var expected_order := 1
	for stage_def in Db.stage_sequence():
		if stage_def.order != expected_order:
			_fail("stage order 불연속: %s (order=%d, 기대=%d)" % [stage_def.id, stage_def.order, expected_order])
		expected_order += 1

func _check_economy_vectors() -> void:
	if Economy.reward_base(1) != 24:
		_fail("VEC-001: reward_base(1)=%d" % Economy.reward_base(1))
	if Economy.reward_first(8, true) != 330:
		_fail("VEC-002: reward_first(8,boss)=%d" % Economy.reward_first(8, true))
	if Economy.level_up_cost(1) != 40:
		_fail("VEC-003: cost(1)=%d" % Economy.level_up_cost(1))
	if Economy.level_up_cost(5) != 262:
		_fail("VEC-004: cost(5)=%d" % Economy.level_up_cost(5))
	var total := 0
	for level in range(1, Economy.LEVEL_MAX):
		total += Economy.level_up_cost(level)
	if total != 4511:
		_fail("VEC-005: 누적 비용=%d" % total)
	if not is_equal_approx(CombatRules.level_mult(10), 2.08):
		_fail("VEC-006: level_mult(10)=%f" % CombatRules.level_mult(10))

## run 스냅숏 → BattleConfig 복원 계약 검증. 실제 저장 파일은 건드리지 않는다 (메모리 교체 후 원복).
func _check_battle_config_restore() -> void:
	var original: Dictionary = SaveService.data
	SaveService.data = SaveService._defaults()
	SaveService.data["run"] = {
		"stage_id": "1-2", "wave_index": 2, "base_hp": 55.0,
		"reinforce_gauge": 40.0, "rng_seed": 777, "leader": "b_cell",
		"upgrades": ["u_crit", "u_atk_all"],
	}
	var config := GameState.build_battle_config(&"1-2", Vector2(390.0, 844.0), true)
	if config.start_wave_index != 2:
		_fail("restore: wave_index=%d" % config.start_wave_index)
	if not is_equal_approx(config.start_base_hp, 55.0):
		_fail("restore: base_hp=%f" % config.start_base_hp)
	if config.roster.is_empty() or config.roster[0].id != &"b_cell":
		_fail("restore: 리더 복원 실패")
	var expected_upgrades: Array[StringName] = [&"u_crit", &"u_atk_all"]
	if config.upgrade_ids != expected_upgrades:
		_fail("restore: 강화 복원 실패 %s" % str(config.upgrade_ids))
	if config.rng_seed != 777:
		_fail("restore: rng_seed=%d" % config.rng_seed)
	SaveService.data = original

func _check_save_roundtrip() -> void:
	var svc := _isolated_save_service("test_save.json")
	add_child(svc)
	await get_tree().process_frame

	svc.data["meta"]["currency"] = 777
	svc.data["flags"]["tutorial_done"] = true
	svc.flush_now()

	var reloaded := _isolated_save_service("test_save.json")
	add_child(reloaded)
	await get_tree().process_frame
	if int(reloaded.data["meta"]["currency"]) != 777:
		_fail("save 라운드트립: currency 불일치 (%s)" % str(reloaded.data["meta"]["currency"]))
	if not bool(reloaded.data["flags"]["tutorial_done"]):
		_fail("save 라운드트립: flags 불일치")
	if int(reloaded.data["version"]) != SaveServiceScript.CURRENT_VERSION:
		_fail("save 라운드트립: version 불일치")
	_cleanup_test_files()

func _check_save_corruption_fallback() -> void:
	var svc := _isolated_save_service("test_save.json")
	add_child(svc)
	await get_tree().process_frame
	svc.data["meta"]["currency"] = 42
	svc.flush_now()
	svc.flush_now()

	var corrupted := FileAccess.open("user://test_save.json", FileAccess.WRITE)
	corrupted.store_string("{broken json")
	corrupted.close()

	var recovered := _isolated_save_service("test_save.json")
	add_child(recovered)
	await get_tree().process_frame
	if int(recovered.data["meta"]["currency"]) != 42:
		_fail("손상 폴백: .bak 복구 실패 (currency=%s)" % str(recovered.data["meta"]["currency"]))
	_cleanup_test_files()

func _isolated_save_service(file_name: String) -> Node:
	var svc: Node = SaveServiceScript.new()
	svc.save_path = "user://" + file_name
	svc.backup_path = "user://" + file_name + ".bak"
	svc.tmp_path = "user://" + file_name + ".tmp"
	return svc

func _cleanup_test_files() -> void:
	var dir := DirAccess.open("user://")
	if dir == null:
		return
	for file_name in ["test_save.json", "test_save.json.bak", "test_save.json.tmp"]:
		if dir.file_exists(file_name):
			dir.remove(file_name)
