class_name CellUnit
extends Node2D
## 아군 세포 유닛. 컨트롤러가 step으로 구동한다 — 자체 _process 없음.

var def: CellDef
var is_leader := false
var controller: BattleController
var home_position := Vector2.ZERO
var fire_timer := 0.0
var pulse_seed := 0.0
var level := 1
var active := true
## 증원으로 소환된 임시 세포의 잔여 시간 (음수면 상시).
var expire_timer := -1.0
## AI 생성 스프라이트. 없으면 코드 도형으로 폴백.
var sprite: Texture2D

var is_temporary: bool:
	get:
		return expire_timer > 0.0
var remaining_lifetime: float:
	get:
		return maxf(0.0, expire_timer)

## CON-004: 증원 세포를 지속시간 후 자연 퇴장하도록 표시한다.
func make_temporary(duration: float) -> void:
	expire_timer = duration

func configure(new_def: CellDef, leader: bool, new_controller: BattleController, new_home: Vector2) -> void:
	def = new_def
	is_leader = leader
	controller = new_controller
	home_position = new_home
	position = new_home
	pulse_seed = controller.rng.randf() * TAU

## 컨트롤러가 스폰 직후 호출. 텍스처가 있으면 우선 사용하고, 없으면 코드 도형.
func set_sprite(texture: Texture2D) -> void:
	sprite = texture

func step(delta: float) -> void:
	if expire_timer > 0.0:
		expire_timer -= delta
		if expire_timer <= 0.0:
			active = false
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
				fire_timer = controller.cell_attack_interval(def)
				controller.fire_projectile(self, target, controller.cell_damage(def, level), def.accent)

	position = position.move_toward(ArenaLayout.clamp_to_arena(controller.arena_size, desired), def.speed * delta)
	queue_redraw()

func _draw() -> void:
	var time := Time.get_ticks_msec() * 0.004 + pulse_seed
	var pulse := 1.0 + sin(time) * 0.06
	var radius := 19.0 * pulse
	if is_leader:
		radius = 23.0 * pulse

	if sprite != null:
		# Display diameter ~ radius * 2.55 to match the silhouette weight.
		var size := Vector2.ONE * radius * 2.55
		var top_left := Vector2(-size.x * 0.5, -size.y * 0.5)
		var rect := Rect2(top_left, size)
		# Rim glow underlay for the soft neon outline the style guide requires.
		var glow_color := _with_alpha(def.color, 0.16)
		draw_rect(rect.grow(6.0), glow_color, true)
		draw_texture_rect(sprite, rect, false)
	else:
		draw_circle(Vector2.ZERO, radius + 8.0, _with_alpha(def.color, 0.14))
		draw_circle(Vector2.ZERO, radius, def.color)
		draw_circle(Vector2(-radius * 0.2, -radius * 0.14), radius * 0.42, _with_alpha(def.accent, 0.76))
		draw_circle(Vector2(radius * 0.32, radius * 0.22), radius * 0.22, _with_alpha(Color("#0B2D2A"), 0.26))

	if is_leader:
		draw_arc(Vector2.ZERO, radius + 7.0, -PI * 0.45, PI * 1.45, 48, def.accent, 4.5, true)

func _with_alpha(color: Color, alpha: float) -> Color:
	var copy := color
	copy.a = alpha
	return copy