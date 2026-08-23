extends Node
## user://save.json 로드/저장. version 필드 + 순차 migration, tmp→rename 원자 쓰기 + .bak 폴백.

signal save_error(code: String)

const CURRENT_VERSION := 1
## v(N) → v(N+1) 변환 Callable 목록. index 0 = v1 → v2.
const _MIGRATIONS: Array[Callable] = []

var save_path := "user://save.json"
var backup_path := "user://save.json.bak"
var tmp_path := "user://save.json.tmp"

var data: Dictionary = {}
var _dirty := false
var _flush_timer: Timer

func _ready() -> void:
	_flush_timer = Timer.new()
	_flush_timer.one_shot = true
	_flush_timer.wait_time = 0.5
	_flush_timer.timeout.connect(flush_now)
	add_child(_flush_timer)
	load_data()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _dirty:
			flush_now()

func load_data() -> void:
	var loaded := _read_and_parse(save_path)
	if loaded.is_empty() and FileAccess.file_exists(save_path):
		save_error.emit("parse")
		loaded = _read_and_parse(backup_path)
		if not loaded.is_empty():
			save_error.emit("recovered_from_backup")
	if loaded.is_empty():
		data = _defaults()
		return
	data = _migrate(loaded)
	_apply_defaults(data, _defaults())

func mark_dirty() -> void:
	_dirty = true
	data["updated_at_unix"] = int(Time.get_unix_time_from_system())
	if _flush_timer != null and is_inside_tree():
		_flush_timer.start()

func flush_now() -> void:
	_dirty = false
	var file := FileAccess.open(tmp_path, FileAccess.WRITE)
	if file == null:
		save_error.emit("io")
		return
	file.store_string(JSON.stringify(data))
	file.close()

	var dir := DirAccess.open("user://")
	if dir == null:
		save_error.emit("io")
		return
	if dir.file_exists(save_path.get_file()):
		dir.copy(save_path, backup_path)
	if dir.file_exists(save_path.get_file()):
		dir.remove(save_path)
	if dir.rename(tmp_path, save_path) != OK:
		save_error.emit("io")

func settings() -> Dictionary:
	return data.get("settings", {})

func meta() -> Dictionary:
	return data.get("meta", {})

func flags() -> Dictionary:
	return data.get("flags", {})

func _read_and_parse(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	if text.is_empty():
		return {}
	var json := JSON.new()
	if json.parse(text) != OK or json.data is not Dictionary:
		return {}
	var dict: Dictionary = json.data
	if dict.get("version", 0) is not float and dict.get("version", 0) is not int:
		return {}
	return dict

func _migrate(loaded: Dictionary) -> Dictionary:
	var version := int(loaded.get("version", 0))
	if version < 1 or version > CURRENT_VERSION:
		save_error.emit("migration")
		return _defaults()
	while version < CURRENT_VERSION:
		loaded = _MIGRATIONS[version - 1].call(loaded)
		version += 1
		loaded["version"] = version
	return loaded

func _apply_defaults(target: Dictionary, defaults: Dictionary) -> void:
	for key: Variant in defaults:
		if not target.has(key):
			target[key] = defaults[key]
		elif target[key] is Dictionary and defaults[key] is Dictionary:
			_apply_defaults(target[key], defaults[key])

func _defaults() -> Dictionary:
	return {
		"version": CURRENT_VERSION,
		"updated_at_unix": 0,
		"settings": {"bgm": true, "sfx": true, "haptic": true, "reduced_motion": false},
		"meta": {
			"currency": 0,
			"cells": {
				"macrophage": {"unlocked": true, "level": 1},
				"neutrophil": {"unlocked": true, "level": 1},
				"b_cell": {"unlocked": true, "level": 1},
			},
			"stages": {},
			"last_deck": {"leader": "macrophage", "members": ["neutrophil", "b_cell", ""]},
			"codex_seen": [],
		},
		"run": null,
		"flags": {"tutorial_done": false},
		"client_id": _uuid4(),
	}

func _uuid4() -> String:
	var bytes := Crypto.new().generate_random_bytes(16)
	bytes[6] = (bytes[6] & 0x0F) | 0x40
	bytes[8] = (bytes[8] & 0x3F) | 0x80
	var hex := bytes.hex_encode()
	return "%s-%s-%s-%s-%s" % [hex.substr(0, 8), hex.substr(8, 4), hex.substr(12, 4), hex.substr(16, 4), hex.substr(20, 12)]
