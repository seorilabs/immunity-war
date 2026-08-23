extends Node
## 오디오 버스 구성과 재생 진입점. Phase 1은 버스 셋업만, 스트림 재생은 Phase 3에서 연결한다.

const BUS_BGM := "BGM"
const BUS_SFX := "SFX"

func _ready() -> void:
	_ensure_bus(BUS_BGM)
	_ensure_bus(BUS_SFX)
	apply_settings()

func apply_settings() -> void:
	var settings: Dictionary = SaveService.settings()
	_set_bus_enabled(BUS_BGM, bool(settings.get("bgm", true)))
	_set_bus_enabled(BUS_SFX, bool(settings.get("sfx", true)))

func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		AudioServer.add_bus()
		var index := AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus_name)
		AudioServer.set_bus_send(index, "Master")

func _set_bus_enabled(bus_name: String, enabled: bool) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index != -1:
		AudioServer.set_bus_mute(index, not enabled)
