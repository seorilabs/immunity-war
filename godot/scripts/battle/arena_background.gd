extends Control
class_name ArenaBackground

var base_x := 58.0
var chapter_texture: Texture2D

func setup(stage_id: StringName) -> void:
	chapter_texture = SpriteLoader.try_load(SpriteLoader.background_path(stage_id))

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size := get_rect().size
	draw_rect(Rect2(Vector2.ZERO, size), Color("#061615"), true)

	if chapter_texture != null:
		# Cover the arena while preserving aspect ratio.
		var tex_size := chapter_texture.get_size()
		var scale := maxf(size.x / tex_size.x, size.y / tex_size.y)
		var drawn := tex_size * scale
		var origin := Vector2((size.x - drawn.x) * 0.5, (size.y - drawn.y) * 0.5)
		draw_texture_rect_region(chapter_texture, Rect2(origin, drawn), Rect2(Vector2.ZERO, tex_size))
		# Darken the layer so the foreground lane lines + units still read.
		draw_rect(Rect2(origin, drawn), Color(0.0, 0.0, 0.0, 0.42), true)

	for i in range(11):
		var y := 126.0 + i * 52.0
		var color := Color(0.48, 1.0, 0.78, 0.035 + float(i % 2) * 0.02)
		draw_line(Vector2(base_x + 20.0, y), Vector2(size.x, y + sin(Time.get_ticks_msec() * 0.001 + i) * 12.0), color, 3.0, true)

	for lane in range(3):
		var y := _lane_y(size, lane)
		draw_line(Vector2(base_x + 20.0, y), Vector2(size.x - 8.0, y), Color(0.9, 1.0, 0.9, 0.06), 4.0, true)

	draw_rect(Rect2(0.0, 0.0, size.x, 112.0), Color(0.0, 0.0, 0.0, 0.18), true)
	draw_rect(Rect2(0.0, size.y - 126.0, size.x, 126.0), Color(0.0, 0.0, 0.0, 0.2), true)
	draw_line(Vector2(base_x, 118.0), Vector2(base_x, size.y - 134.0), Color("#B6FFE9"), 7.0, true)
	draw_line(Vector2(base_x + 12.0, 118.0), Vector2(base_x + 12.0, size.y - 134.0), Color(0.68, 1.0, 0.88, 0.13), 24.0, true)

func _lane_y(size: Vector2, lane: int) -> float:
	return lerp(210.0, size.y - 246.0, float(lane) / 2.0)