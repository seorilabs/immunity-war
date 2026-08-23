extends Node2D
class_name CellUnit

var cell_id := ""
var cell_name := ""
var role := ""
var cell_color := Color("#20C7A6")
var accent_color := Color.WHITE
var damage := 10.0
var attack_range := 110.0
var attack_rate := 0.8
var speed := 90.0
var cooldown := 6.0
var hp := 100.0
var is_leader := false
var director: Node
var home_position := Vector2.ZERO
var fire_timer := 0.0
var pulse_seed := 0.0

func setup(new_cell_id: String, data: Dictionary, leader: bool, new_director: Node, new_home_position: Vector2) -> void:
	cell_id = new_cell_id
	cell_name = data["name"]
	role = data["role"]
	cell_color = data["color"]
	accent_color = data["accent"]
	damage = data["damage"]
	attack_range = data["range"]
	attack_rate = data["attack_rate"]
	speed = data["speed"]
	cooldown = data["cooldown"]
	hp = data["hp"]
	is_leader = leader
	director = new_director
	home_position = new_home_position
	position = home_position
	pulse_seed = randf() * TAU

func _process(delta: float) -> void:
	fire_timer = max(0.0, fire_timer - delta)
	var target: Node2D = director.find_nearest_enemy(position, attack_range + 120.0)
	var desired: Vector2 = home_position

	if is_instance_valid(target):
		var target_anchor: Vector2 = target.position - Vector2(attack_range * 0.62, 0.0)
		desired = target_anchor
		if position.distance_to(target.position) <= attack_range:
			desired = position
			if fire_timer <= 0.0:
				fire_timer = attack_rate
				director.fire_projectile(self, target, damage, accent_color)

	position = position.move_toward(director.clamp_to_arena(desired), speed * delta)
	queue_redraw()

func _draw() -> void:
	var time: float = Time.get_ticks_msec() * 0.004 + pulse_seed
	var pulse: float = 1.0 + sin(time) * 0.06
	var radius: float = 19.0 * pulse
	if is_leader:
		radius = 23.0 * pulse

	draw_circle(Vector2.ZERO, radius + 8.0, _with_alpha(cell_color, 0.14))
	draw_circle(Vector2.ZERO, radius, cell_color)
	draw_circle(Vector2(-radius * 0.2, -radius * 0.14), radius * 0.42, _with_alpha(accent_color, 0.76))
	draw_circle(Vector2(radius * 0.32, radius * 0.22), radius * 0.22, _with_alpha(Color("#0B2D2A"), 0.26))

	if is_leader:
		draw_arc(Vector2.ZERO, radius + 7.0, -PI * 0.45, PI * 1.45, 48, accent_color, 3.5, true)

func _with_alpha(color: Color, alpha: float) -> Color:
	var copy := color
	copy.a = alpha
	return copy
