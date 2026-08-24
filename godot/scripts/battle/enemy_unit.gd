class_name EnemyUnit
extends Node2D
## 적 박테리아 유닛. 컨트롤러가 step으로 구동한다.

var def: EnemyDef
var controller: BattleController
var hp := 30.0
var alive := true
var stun_timer := 0.0
var mark_timer := 0.0
var flash_timer := 0.0
var wobble_seed := 0.0

var max_hp := 30.0
var slow_timer := 0.0
var slow_factor := 0.0

func configure(new_def: EnemyDef, new_controller: BattleController, hp_mult: float = 1.0) -> void:
	def = new_def
	controller = new_controller
	max_hp = new_def.hp * hp_mult
	hp = max_hp
	wobble_seed = controller.rng.randf() * TAU

func step(delta: float) -> void:
	if not alive:
		return

	flash_timer = maxf(0.0, flash_timer - delta)
	mark_timer = maxf(0.0, mark_timer - delta)
	slow_timer = maxf(0.0, slow_timer - delta)
	if stun_timer > 0.0:
		stun_timer -= delta
	else:
		var speed_mult := controller.enemy_speed_mult(position.x)
		if slow_timer > 0.0:
			speed_mult *= 1.0 - slow_factor
		position.x -= def.speed * speed_mult * delta
		position.y += sin(Time.get_ticks_msec() * 0.006 + wobble_seed) * 2.4 * delta

	if position.x <= ArenaLayout.BASE_X:
		alive = false
		controller.on_base_reached(self)
		queue_free()
		return

	queue_redraw()

func take_damage(amount: float, attack_tags: Array[StringName] = []) -> void:
	if not alive:
		return
	var mult := CombatRules.type_mult(attack_tags, def.tags)
	if mark_timer > 0.0:
		mult *= controller.mark_mult()
	if controller.roll_crit():
		mult *= CombatRules.CRIT_MULT
	hp -= amount * mult
	flash_timer = 0.12
	if hp <= 0.0:
		alive = false
		controller.on_enemy_defeated(self)
		queue_free()
	else:
		queue_redraw()

func apply_slow(duration: float, factor: float) -> void:
	slow_timer = maxf(slow_timer, duration)
	slow_factor = maxf(slow_factor, factor)

func apply_mark(duration: float) -> void:
	mark_timer = maxf(mark_timer, duration)
	queue_redraw()

func apply_stun(duration: float) -> void:
	stun_timer = maxf(stun_timer, duration)

func pull_toward(point: Vector2, amount: float) -> void:
	position = position.move_toward(point, amount)

func threat_score() -> float:
	return CombatRules.threat_score(hp, position.x, def.base_damage)

func _draw() -> void:
	var time := Time.get_ticks_msec() * 0.004 + wobble_seed
	var stretch := 1.0 + sin(time) * 0.08
	var body_color := def.color
	if flash_timer > 0.0:
		body_color = body_color.lerp(Color.WHITE, 0.62)

	var half_len := def.radius * 1.45 * stretch
	var half_height := def.radius * 0.72 / stretch
	draw_rect(Rect2(Vector2(-half_len, -half_height), Vector2(half_len * 2.0, half_height * 2.0)), body_color, true)
	draw_circle(Vector2(-half_len, 0.0), half_height, body_color)
	draw_circle(Vector2(half_len, 0.0), half_height, body_color)

	var shine := body_color.lerp(Color.WHITE, 0.45)
	shine.a = 0.5
	draw_circle(Vector2(-def.radius * 0.55, -def.radius * 0.22), def.radius * 0.18, shine)
	draw_circle(Vector2(def.radius * 0.45, def.radius * 0.18), def.radius * 0.14, shine)

	if mark_timer > 0.0:
		var mark_color := Color("#BFE9FF")
		mark_color.a = 0.9
		draw_arc(Vector2.ZERO, def.radius * 1.55, -PI * 0.2, PI * 1.4, 34, mark_color, 4.0, true)
		draw_circle(Vector2(def.radius * 1.2, -def.radius * 1.0), 4.0, mark_color)

	if stun_timer > 0.0:
		var stun_color := Color("#FFF6B8")
		stun_color.a = 0.85
		draw_arc(Vector2.ZERO, def.radius * 1.7, 0.0, TAU * 0.82, 28, stun_color, 4.0, true)

	var bar_width := def.radius * 2.4
	var hp_ratio := clampf(hp / max_hp, 0.0, 1.0)
	draw_rect(Rect2(-bar_width * 0.5, -def.radius * 1.8, bar_width, 3.0), Color(0, 0, 0, 0.28), true)
	draw_rect(Rect2(-bar_width * 0.5, -def.radius * 1.8, bar_width * hp_ratio, 3.0), Color("#F7FFF9"), true)
