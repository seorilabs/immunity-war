extends Node
## 헤드리스 스모크: main_scene 존재, Db 무결성, CombatRules test vector, 강화 3택, 증원 게이지, 일시정지, SaveService 라운드트립·손상 폴백.

const SaveServiceScript := preload("res://scripts/autoload/save_service.gd")
const CombatRulesTest := preload("res://tests/combat_rules_test.gd")
const UpgradePoolTest := preload("res://tests/upgrade_pool_test.gd")
const UpgradeOverlayTest := preload("res://tests/upgrade_overlay_test.gd")
const ReinforceTest := preload("res://tests/reinforce_test.gd")
const BattleScreenTest := preload("res://tests/battle_screen_test.gd")
const PauseTest := preload("res://tests/pause_test.gd")
const PauseOverlayTest := preload("res://tests/pause_overlay_test.gd")

var _failures: PackedStringArray = []

func _ready() -> void:
	_check_main_scene()
	_check_db()
	_check_combat_rules()
	_check_upgrades()
	_check_reinforce()
	_check_pause()
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
	if Db.stage(&"1-1") == null:
		_fail("stage 1-1 누락")

func _check_combat_rules() -> void:
	for message in CombatRulesTest.run():
		_fail("CombatRules: " + message)

func _check_upgrades() -> void:
	for message in UpgradePoolTest.run(self):
		_fail("강화 3택: " + message)
	for message in UpgradeOverlayTest.run(self):
		_fail("강화 오버레이: " + message)

func _check_reinforce() -> void:
	for message in ReinforceTest.run(self):
		_fail("증원 게이지: " + message)
	for message in BattleScreenTest.run(self):
		_fail("전투 화면 배선: " + message)

func _check_pause() -> void:
	for message in PauseTest.run(self):
		_fail("일시정지: " + message)
	for message in PauseOverlayTest.run(self):
		_fail("일시정지 오버레이: " + message)

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
