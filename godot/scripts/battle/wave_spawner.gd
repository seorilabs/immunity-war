class_name WaveSpawner
extends RefCounted
## WaveDef를 시간순 스폰 이벤트로 전개하고 경과 시간에 따라 소비한다.

var _events: Array[Dictionary] = []
var _cursor := 0

func load_wave(wave: WaveDef) -> void:
	_events.clear()
	_cursor = 0
	for entry in wave.spawns:
		for i in range(entry.count):
			_events.append({
				"time": entry.time + float(i) * entry.spacing,
				"enemy": entry.enemy,
				"lane": entry.lane,
			})
	_events.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["time"] < b["time"])

## wave_elapsed 시점까지 도래한 이벤트를 반환하고 커서를 전진시킨다.
func pop_due(wave_elapsed: float) -> Array[Dictionary]:
	var due: Array[Dictionary] = []
	while _cursor < _events.size() and _events[_cursor]["time"] <= wave_elapsed:
		due.append(_events[_cursor])
		_cursor += 1
	return due

func is_exhausted() -> bool:
	return _cursor >= _events.size()
