extends Node2D
class_name FxNode

var kind := "ring"
var radius := 80.0
var lifetime := 0.55
var age := 0.0
var fx_color := Color.WHITE

func setup(new_kind: String, new_radius: float, new_color: Color, new_lifetime: float = 0.55) -> void:
	kind = new_kind
	radius = new_radius
	fx_color = new_color
	lifetime = max(new_lifetime, 0.05)

func _process(delta: float) -> void:
	age += delta
	queue_redraw()
	if age >= lifetime:
		queue_free()

func _draw() -> void:
	var progress: float = clamp(age / lifetime, 0.0, 1.0)
	var alpha: float = 1.0 - progress
	var color: Color = fx_color
	color.a *= alpha

	if kind == "blast":
		draw_circle(Vector2.ZERO, radius * (0.35 + progress * 0.65), _with_alpha(color, 0.18 * alpha))
		draw_arc(Vector2.ZERO, radius * (0.8 + progress * 0.25), 0.0, TAU, 56, color, 8.0, true)
	elif kind == "mark":
		for i in range(3):
			var angle: float = progress * TAU + float(i) * TAU / 3.0
			var point: Vector2 = Vector2(cos(angle), sin(angle)) * radius * 0.45
			draw_circle(point, 5.0 + progress * 3.0, color)
		draw_arc(Vector2.ZERO, radius * 0.58, -PI * 0.4, PI * 1.4, 44, color, 4.0, true)
	else:
		draw_circle(Vector2.ZERO, radius * progress, _with_alpha(color, 0.12 * alpha))
		draw_arc(Vector2.ZERO, radius * (0.55 + progress * 0.45), 0.0, TAU, 52, color, 5.0, true)

func _with_alpha(color: Color, alpha: float) -> Color:
	var copy := color
	copy.a = alpha
	return copy
