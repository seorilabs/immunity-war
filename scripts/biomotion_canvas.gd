extends Control
class_name BiomotionCanvas

var mode := "preview"
var start_msec := 0

func _ready() -> void:
	start_msec = Time.get_ticks_msec()
	set_process(true)

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var size := get_rect().size
	var elapsed := float(Time.get_ticks_msec() - start_msec) / 1000.0
	draw_rect(Rect2(Vector2.ZERO, size), Color("#0B2D2A"), true)

	for i in range(7):
		var y := size.y * (0.14 + i * 0.12)
		var alpha := 0.06 + 0.03 * sin(elapsed + i)
		draw_line(Vector2(0.0, y), Vector2(size.x, y + sin(elapsed * 0.7 + i) * 12.0), Color(0.7, 1.0, 0.85, alpha), 1.5, true)

	var base_x := size.x * 0.23
	draw_line(Vector2(base_x, 0.0), Vector2(base_x, size.y), Color("#B6FFE9"), 5.0, true)
	draw_line(Vector2(base_x + 9.0, 0.0), Vector2(base_x + 9.0, size.y), Color(0.7, 1.0, 0.88, 0.12), 18.0, true)

	var bacteria_count := 9
	for i in range(bacteria_count):
		var progress: float = fmod(elapsed * (0.15 + float(i) * 0.015) + float(i) * 0.17, 1.0)
		if mode == "intro":
			progress = clamp(elapsed / 1.9 + float(i) * 0.035, 0.0, 1.0)
		var x: float = lerp(size.x + 40.0, base_x + 34.0, progress)
		var y: float = size.y * (0.18 + fmod(float(i) * 0.31, 0.7)) + sin(elapsed * 2.0 + float(i)) * 10.0
		_draw_bacteria(Vector2(x, y), 9.0 + float(i % 3) * 2.0, Color("#F45656").lerp(Color("#FF8D42"), float(i % 2) * 0.28), elapsed + i)

	var cell_positions := [
		Vector2(base_x + 50.0, size.y * 0.33),
		Vector2(base_x + 72.0, size.y * 0.55),
		Vector2(base_x + 44.0, size.y * 0.73)
	]
	var colors := [Color("#28D2A3"), Color("#F2D95C"), Color("#63B3FF")]
	for i in range(cell_positions.size()):
		_draw_cell(cell_positions[i] + Vector2(sin(elapsed + i) * 4.0, cos(elapsed * 1.2 + i) * 3.0), 19.0, colors[i], elapsed + i)

func _draw_cell(pos: Vector2, radius: float, color: Color, t: float) -> void:
	var pulse := 1.0 + sin(t * 2.5) * 0.08
	draw_circle(pos, radius * pulse + 8.0, _with_alpha(color, 0.13))
	draw_circle(pos, radius * pulse, color)
	draw_circle(pos + Vector2(-4.0, -3.0), radius * 0.38, Color("#F7FFF9"))
	draw_circle(pos + Vector2(6.0, 5.0), radius * 0.18, Color(0.0, 0.0, 0.0, 0.16))

func _draw_bacteria(pos: Vector2, radius: float, color: Color, t: float) -> void:
	var stretch := 1.0 + sin(t * 3.0) * 0.12
	var half_len := radius * 1.35 * stretch
	var half_height := radius * 0.72 / stretch
	draw_rect(Rect2(pos - Vector2(half_len, half_height), Vector2(half_len * 2.0, half_height * 2.0)), color, true)
	draw_circle(pos + Vector2(-half_len, 0.0), half_height, color)
	draw_circle(pos + Vector2(half_len, 0.0), half_height, color)

func _with_alpha(color: Color, alpha: float) -> Color:
	var copy := color
	copy.a = alpha
	return copy
