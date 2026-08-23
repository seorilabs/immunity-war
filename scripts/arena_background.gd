extends Control
class_name ArenaBackground

var base_x := 58.0

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size := get_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("#061615"), true)

	for i in range(11):
		var y := 126.0 + i * 52.0
		var color := Color(0.48, 1.0, 0.78, 0.035 + float(i % 2) * 0.02)
		draw_line(Vector2(base_x + 20.0, y), Vector2(size.x, y + sin(Time.get_ticks_msec() * 0.001 + i) * 12.0), color, 2.0, true)

	for lane in range(3):
		var y := _lane_y(size, lane)
		draw_line(Vector2(base_x + 20.0, y), Vector2(size.x - 8.0, y), Color(0.9, 1.0, 0.9, 0.06), 3.0, true)

	draw_rect(Rect2(0.0, 0.0, size.x, 112.0), Color(0.0, 0.0, 0.0, 0.18), true)
	draw_rect(Rect2(0.0, size.y - 126.0, size.x, 126.0), Color(0.0, 0.0, 0.0, 0.2), true)
	draw_line(Vector2(base_x, 118.0), Vector2(base_x, size.y - 134.0), Color("#B6FFE9"), 7.0, true)
	draw_line(Vector2(base_x + 12.0, 118.0), Vector2(base_x + 12.0, size.y - 134.0), Color(0.68, 1.0, 0.88, 0.13), 24.0, true)

func _lane_y(size: Vector2, lane: int) -> float:
	return lerp(210.0, size.y - 246.0, float(lane) / 2.0)

