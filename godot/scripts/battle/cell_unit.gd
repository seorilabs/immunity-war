class_name CellUnit
extends Node2D
## 아군 세포 유닛. 컨트롤러가 step으로 구동한다 — 자체 _process 없음.

var def: CellDef
var is_leader := false
var controller: BattleController
var home_position := Vector2.ZERO
var fire_timer := 0.0
var pulse_seed := 0.0
## 0보다 크면 증원으로 투입된 임시 세포 — 남은 시간이 0이 되면 스스로 퇴장한다 (CON-004).
var remaining_lifetime := 0.0
var is_temporary := false

func configure(new_def: CellDef, leader: bool, new_controller: BattleController, new_home: Vector2) -> void:
	def = new_def
	is_leader = leader
	controller = new_controller
	home_position = new_home
	position = new_home
	pulse_seed = controller.rng.randf() * TAU

## 임시 증원 세포로 전환한다. 리더 표식은 갖지 않는다.
func make_temporary(duration: float) -> void:
	is_temporary = true
	is_leader = false
	remaining_lifetime = duration

func step(delta: float) -> void:
	if is_temporary:
		remaining_lifetime -= delta
		if remaining_lifetime <= 0.0:
			controller.on_reinforcement_expired(self)
			queue_free()
			return

	fire_timer = maxf(0.0, fire_timer - delta)
	var target := controller.registry.find_nearest_enemy(position, def.attack_range + 120.0)
	var desired := home_position

	if is_instance_valid(target):
		desired = target.position - Vector2(def.attack_range * 0.62, 0.0)
		if position.distance_to(target.position) <= def.attack_range:
			desired = position
			if fire_timer <= 0.0:
				fire_timer = def.attack_rate * controller.run_upgrades.attack_rate_mult
				controller.fire_projectile(self, target, def.damage, def.accent)

	position = position.move_toward(ArenaLayout.clamp_to_arena(controller.arena_size, desired), def.speed * delta)
	queue_redraw()

func _draw() -> void:
	var time := Time.get_ticks_msec() * 0.004 + pulse_seed
	var pulse := 1.0 + sin(time) * 0.06
	var radius := 19.0 * pulse
	if is_leader:
		radius = 23.0 * pulse

	draw_circle(Vector2.ZERO, radius + 8.0, _with_alpha(def.color, 0.14))
	draw_circle(Vector2.ZERO, radius, def.color)
	draw_circle(Vector2(-radius * 0.2, -radius * 0.14), radius * 0.42, _with_alpha(def.accent, 0.76))
	draw_circle(Vector2(radius * 0.32, radius * 0.22), radius * 0.22, _with_alpha(Color("#0B2D2A"), 0.26))

	if is_leader:
		draw_arc(Vector2.ZERO, radius + 7.0, -PI * 0.45, PI * 1.45, 48, def.accent, 4.5, true)

	if is_temporary:
		var fade := clampf(remaining_lifetime / 3.0, 0.35, 1.0)
		draw_arc(Vector2.ZERO, radius + 5.0, 0.0, TAU, 40, _with_alpha(UiStyle.SUCCESS, 0.55 * fade), 2.5, true)

func _with_alpha(color: Color, alpha: float) -> Color:
	var copy := color
	copy.a = alpha
	return copy
