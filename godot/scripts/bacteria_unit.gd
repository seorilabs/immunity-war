extends Node2D
class_name BacteriaUnit

var enemy_id := ""
var enemy_name := ""
var max_hp := 30.0
var hp := 30.0
var speed := 35.0
var base_damage := 8.0
var radius := 12.0
var enemy_color := Color("#F45656")
var director: Node
var alive := true
var stun_timer := 0.0
var mark_timer := 0.0
var flash_timer := 0.0
var wobble_seed := 0.0

func setup(new_enemy_id: String, data: Dictionary, new_director: Node) -> void:
	enemy_id = new_enemy_id
	enemy_name = data["name"]
	max_hp = data["hp"]
	hp = max_hp
	speed = data["speed"]
	base_damage = data["damage"]
	enemy_color = data["color"]
	radius = data["radius"]
	director = new_director
	wobble_seed = randf() * TAU

func _process(delta: float) -> void:
	if not alive:
		return

	flash_timer = max(0.0, flash_timer - delta)
	mark_timer = max(0.0, mark_timer - delta)
	if stun_timer > 0.0:
		stun_timer -= delta
	else:
		position.x -= speed * delta
		position.y += sin(Time.get_ticks_msec() * 0.006 + wobble_seed) * 2.4 * delta

	if position.x <= director.get_base_x():
		alive = false
		director.damage_base(base_damage)
		director.spawn_fx(global_position, "blast", radius * 2.2, enemy_color, 0.35)
		queue_free()
		return

	queue_redraw()

func take_damage(amount: float, _source_cell_id: String = "") -> void:
	if not alive:
		return

	var final_damage := amount
	if mark_timer > 0.0:
		final_damage *= 1.45
	hp -= final_damage
	flash_timer = 0.12
	if hp <= 0.0:
		alive = false
		director.enemy_defeated(self)
		director.spawn_fx(global_position, "ring", radius * 2.0, enemy_color, 0.34)
		queue_free()
	else:
		queue_redraw()

func apply_mark(duration: float) -> void:
	mark_timer = max(mark_timer, duration)
	queue_redraw()

func apply_stun(duration: float) -> void:
	stun_timer = max(stun_timer, duration)

func pull_toward(point: Vector2, amount: float) -> void:
	position = position.move_toward(point, amount)

func threat_score() -> float:
	return hp + max(0.0, 280.0 - position.x) * 0.35 + base_damage * 2.0

func _draw() -> void:
	var time := Time.get_ticks_msec() * 0.004 + wobble_seed
	var stretch := 1.0 + sin(time) * 0.08
	var body_color := enemy_color
	if flash_timer > 0.0:
		body_color = body_color.lerp(Color.WHITE, 0.62)

	var half_len := radius * 1.45 * stretch
	var half_height := radius * 0.72 / stretch
	draw_rect(Rect2(Vector2(-half_len, -half_height), Vector2(half_len * 2.0, half_height * 2.0)), body_color, true)
	draw_circle(Vector2(-half_len, 0.0), half_height, body_color)
	draw_circle(Vector2(half_len, 0.0), half_height, body_color)

	var shine := body_color.lerp(Color.WHITE, 0.45)
	shine.a = 0.5
	draw_circle(Vector2(-radius * 0.55, -radius * 0.22), radius * 0.18, shine)
	draw_circle(Vector2(radius * 0.45, radius * 0.18), radius * 0.14, shine)

	if mark_timer > 0.0:
		var mark_color := Color("#BFE9FF")
		mark_color.a = 0.9
		draw_arc(Vector2.ZERO, radius * 1.55, -PI * 0.2, PI * 1.4, 34, mark_color, 4.0, true)
		draw_circle(Vector2(radius * 1.2, -radius * 1.0), 4.0, mark_color)

	if stun_timer > 0.0:
		var stun_color := Color("#FFF6B8")
		stun_color.a = 0.85
		draw_arc(Vector2.ZERO, radius * 1.7, 0.0, TAU * 0.82, 28, stun_color, 4.0, true)

	var bar_width: float = radius * 2.4
	var hp_ratio: float = clamp(hp / max_hp, 0.0, 1.0)
	draw_rect(Rect2(-bar_width * 0.5, -radius * 1.8, bar_width, 3.0), Color(0, 0, 0, 0.28), true)
	draw_rect(Rect2(-bar_width * 0.5, -radius * 1.8, bar_width * hp_ratio, 3.0), Color("#F7FFF9"), true)
