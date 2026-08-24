class_name Projectile
extends Node2D
## 유도 투사체. 컨트롤러가 step으로 구동한다.

var target: EnemyUnit
var damage := 8.0
var speed := 320.0
var projectile_color := Color.WHITE
var attack_tags: Array[StringName] = []

func configure(new_target: EnemyUnit, new_damage: float, new_color: Color, new_attack_tags: Array[StringName]) -> void:
	target = new_target
	damage = new_damage
	projectile_color = new_color
	attack_tags = new_attack_tags

func step(delta: float) -> void:
	if not is_instance_valid(target) or not target.alive:
		queue_free()
		return

	var to_target := target.position - position
	if to_target.length() <= maxf(12.0, speed * delta):
		target.take_damage(damage, attack_tags)
		queue_free()
		return

	position += to_target.normalized() * speed * delta
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
