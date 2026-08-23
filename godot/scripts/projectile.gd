extends Node2D
class_name Projectile

var target: Node2D
var damage := 8.0
var speed := 320.0
var projectile_color := Color.WHITE
var source_cell_id := ""

func setup(new_target: Node2D, new_damage: float, new_color: Color, new_source_cell_id: String) -> void:
	target = new_target
	damage = new_damage
	projectile_color = new_color
	source_cell_id = new_source_cell_id

func _process(delta: float) -> void:
	if not is_instance_valid(target) or not target.alive:
		queue_free()
		return

	var to_target := target.global_position - global_position
	if to_target.length() <= max(12.0, speed * delta):
		target.take_damage(damage, source_cell_id)
		queue_free()
		return

	global_position += to_target.normalized() * speed * delta
	rotation = to_target.angle()
	queue_redraw()

func _draw() -> void:
	var tail := Vector2(-10.0, 0.0)
	draw_line(tail, Vector2.ZERO, _with_alpha(projectile_color, 0.42), 6.0, true)
	draw_circle(Vector2.ZERO, 4.8, projectile_color)
	draw_circle(Vector2.ZERO, 9.0, _with_alpha(projectile_color, 0.22))

func _with_alpha(color: Color, alpha: float) -> Color:
	var copy := color
	copy.a = alpha
	return copy

