extends Control
class_name BattleDirector

signal battle_finished(summary: Dictionary)

const GameDataScript := preload("res://scripts/game_data.gd")
const CellUnitScript := preload("res://scripts/cell_unit.gd")
const BacteriaUnitScript := preload("res://scripts/bacteria_unit.gd")
const ProjectileScript := preload("res://scripts/projectile.gd")
const FxNodeScript := preload("res://scripts/fx_node.gd")
const ArenaBackgroundScript := preload("res://scripts/arena_background.gd")

var leader_id := "macrophage"
var leader: Node2D
var cells: Array = []
var enemies: Array = []
var projectiles: Array = []
var world: Node2D
var background: Control
var top_label: Label
var hp_label: Label
var wave_label: Label
var status_label: Label
var skill_button: Button
var retreat_button: Button
var cooldown_bar: ProgressBar

var base_hp := 120.0
var max_base_hp := 120.0
var elapsed := 0.0
var state := "idle"
var wave_index := -1
var wave_elapsed := 0.0
var spawn_events: Array = []
var spawn_cursor := 0
var between_timer := 0.0
var defeated_count := 0
var skill_cooldown := 0.0
var skill_max_cooldown := 6.0
var battle_started := false
var pending_leader_id := ""

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_scene()
	if not pending_leader_id.is_empty():
		call_deferred("_consume_pending_start")

func start(new_leader_id: String) -> void:
	pending_leader_id = new_leader_id
	if world == null or not is_inside_tree():
		call_deferred("_consume_pending_start")
		return
	_consume_pending_start()

func _consume_pending_start() -> void:
	if pending_leader_id.is_empty():
		return
	if world == null or status_label == null:
		call_deferred("_consume_pending_start")
		return
	var new_leader_id := pending_leader_id
	pending_leader_id = ""
	_begin_start(new_leader_id)

func _begin_start(new_leader_id: String) -> void:
	leader_id = new_leader_id
	battle_started = true
	base_hp = max_base_hp
	elapsed = 0.0
	defeated_count = 0
	skill_cooldown = 0.0
	skill_max_cooldown = GameDataScript.CELLS[leader_id]["cooldown"]
	for child in world.get_children():
		child.queue_free()
	cells.clear()
	enemies.clear()
	projectiles.clear()
	_spawn_cells()
	_start_wave(0)

func _build_scene() -> void:
	background = ArenaBackgroundScript.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	world = Node2D.new()
	add_child(world)

	var top_panel := PanelContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 14.0
	top_panel.offset_top = 12.0
	top_panel.offset_right = -14.0
	top_panel.offset_bottom = 98.0
	top_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.12, 0.11, 0.82), Color(0.55, 1.0, 0.82, 0.18)))
	add_child(top_panel)

	var top_grid := GridContainer.new()
	top_grid.columns = 3
	top_grid.add_theme_constant_override("h_separation", 8)
	top_grid.add_theme_constant_override("v_separation", 4)
	top_panel.add_child(top_grid)

	hp_label = _metric_label("체력 120")
	wave_label = _metric_label("웨이브 1/3")
	top_label = _metric_label("00:00")
	top_grid.add_child(hp_label)
	top_grid.add_child(wave_label)
	top_grid.add_child(top_label)

	status_label = Label.new()
	status_label.text = "면역 세포 배치 중"
	status_label.clip_text = true
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.modulate = Color("#D8FFF2")
	top_grid.add_child(status_label)
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_grid.add_child(_metric_label(""))
	top_grid.add_child(_metric_label(""))

	var bottom_panel := PanelContainer.new()
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_left = 14.0
	bottom_panel.offset_right = -14.0
	bottom_panel.offset_top = -112.0
	bottom_panel.offset_bottom = -14.0
	bottom_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.12, 0.11, 0.86), Color(0.55, 1.0, 0.82, 0.18)))
	add_child(bottom_panel)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	bottom_panel.add_child(action_row)

	var skill_box := VBoxContainer.new()
	skill_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(skill_box)

	skill_button = Button.new()
	skill_button.custom_minimum_size = Vector2(0.0, 54.0)
	skill_button.pressed.connect(_use_leader_skill)
	skill_box.add_child(skill_button)

	cooldown_bar = ProgressBar.new()
	cooldown_bar.show_percentage = false
	cooldown_bar.min_value = 0.0
	cooldown_bar.max_value = 1.0
	cooldown_bar.value = 1.0
	cooldown_bar.custom_minimum_size = Vector2(0.0, 8.0)
	skill_box.add_child(cooldown_bar)

	retreat_button = Button.new()
	retreat_button.text = "철수"
	retreat_button.custom_minimum_size = Vector2(74.0, 54.0)
	retreat_button.pressed.connect(func() -> void: _finish(false, "철수"))
	action_row.add_child(retreat_button)

func _process(delta: float) -> void:
	if not battle_started or state == "finished":
		return

	elapsed += delta
	skill_cooldown = max(0.0, skill_cooldown - delta)
	_prune_units()

	if state == "running":
		wave_elapsed += delta
		while spawn_cursor < spawn_events.size() and spawn_events[spawn_cursor]["time"] <= wave_elapsed:
			_spawn_enemy(spawn_events[spawn_cursor])
			spawn_cursor += 1

		if spawn_cursor >= spawn_events.size() and enemies.is_empty():
			if wave_index >= GameDataScript.WAVES.size() - 1:
				_finish(true, "방어 성공")
			else:
				state = "between"
				between_timer = 1.4
				status_label.text = "다음 침투를 감지 중"
	elif state == "between":
		between_timer -= delta
		if between_timer <= 0.0:
			_start_wave(wave_index + 1)

	_update_hud()

func get_base_x() -> float:
	return 58.0

func clamp_to_arena(point: Vector2) -> Vector2:
	var size := get_viewport_rect().size
	return Vector2(
		clamp(point.x, get_base_x() + 34.0, size.x - 54.0),
		clamp(point.y, 138.0, size.y - 154.0)
	)

func find_nearest_enemy(from_position: Vector2, max_distance: float = 9999.0) -> Node2D:
	var best: Node2D = null
	var best_distance := max_distance
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.alive:
			var dist: float = from_position.distance_to(enemy.position)
			if dist < best_distance:
				best = enemy
				best_distance = dist
	return best

func fire_projectile(source: Node2D, target: Node2D, damage: float, color: Color) -> void:
	if not is_instance_valid(target):
		return
	var projectile := ProjectileScript.new()
	projectile.global_position = source.global_position
	projectile.setup(target, damage, color, source.cell_id)
	world.add_child(projectile)
	projectiles.append(projectile)

func damage_base(amount: float) -> void:
	if state == "finished":
		return
	base_hp = max(0.0, base_hp - amount)
	status_label.text = "조직 경계 손상 -" + str(int(amount))
	if base_hp <= 0.0:
		_finish(false, "방어 실패")

func enemy_defeated(_enemy: Node2D) -> void:
	defeated_count += 1

func spawn_fx(global_pos: Vector2, kind: String, radius: float, color: Color, lifetime: float = 0.55) -> void:
	var fx := FxNodeScript.new()
	fx.global_position = global_pos
	fx.setup(kind, radius, color, lifetime)
	world.add_child(fx)

func _spawn_cells() -> void:
	var size := get_viewport_rect().size
	var ids := [leader_id]
	ids.append_array(GameDataScript.teammate_ids(leader_id))
	var homes := [
		Vector2(106.0, _lane_y(size, 1)),
		Vector2(94.0, _lane_y(size, 0)),
		Vector2(96.0, _lane_y(size, 2))
	]

	for i in range(ids.size()):
		var cell := CellUnitScript.new()
		cell.setup(ids[i], GameDataScript.CELLS[ids[i]], i == 0, self, homes[i])
		world.add_child(cell)
		cells.append(cell)
		if i == 0:
			leader = cell

func _start_wave(index: int) -> void:
	wave_index = index
	wave_elapsed = 0.0
	spawn_cursor = 0
	state = "running"
	spawn_events.clear()

	var wave: Dictionary = GameDataScript.WAVES[wave_index]
	for spawn in wave["spawns"]:
		for i in range(spawn["count"]):
			spawn_events.append({
				"time": spawn["time"] + float(i) * spawn["spacing"],
				"enemy": spawn["enemy"],
				"lane": spawn["lane"]
			})
	spawn_events.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["time"] < b["time"])
	status_label.text = wave["name"]
	_update_hud()

func _spawn_enemy(event: Dictionary) -> void:
	var size := get_viewport_rect().size
	var enemy_id: String = event["enemy"]
	var lane: int = event["lane"]
	var enemy := BacteriaUnitScript.new()
	enemy.setup(enemy_id, GameDataScript.ENEMIES[enemy_id], self)
	enemy.position = Vector2(size.x + 42.0 + randf_range(0.0, 24.0), _lane_y(size, lane) + randf_range(-18.0, 18.0))
	world.add_child(enemy)
	enemies.append(enemy)

func _use_leader_skill() -> void:
	if skill_cooldown > 0.0 or not is_instance_valid(leader) or state != "running":
		return

	skill_cooldown = skill_max_cooldown
	var data: Dictionary = GameDataScript.CELLS[leader_id]
	status_label.text = data["skill_name"]

	if leader_id == "macrophage":
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.alive and enemy.position.distance_to(leader.position) <= 145.0:
				enemy.pull_toward(leader.position + Vector2(58.0, 0.0), 64.0)
				enemy.apply_stun(1.15)
				enemy.take_damage(16.0, leader_id)
		spawn_fx(leader.global_position, "ring", 145.0, data["accent"], 0.55)
	elif leader_id == "neutrophil":
		var center: Vector2 = leader.position + Vector2(96.0, 0.0)
		for enemy in enemies:
			if is_instance_valid(enemy) and enemy.alive and enemy.position.distance_to(center) <= 118.0:
				enemy.take_damage(42.0, leader_id)
		spawn_fx(world.global_position + center, "blast", 118.0, data["accent"], 0.45)
	else:
		var target: Node2D = _highest_threat_enemy()
		if is_instance_valid(target):
			target.apply_mark(6.0)
			target.take_damage(12.0, leader_id)
			spawn_fx(target.global_position, "mark", 70.0, data["accent"], 0.7)

	_update_hud()

func _highest_threat_enemy() -> Node2D:
	var best: Node2D = null
	var best_score := -1.0
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.alive:
			var score: float = enemy.threat_score()
			if score > best_score:
				best_score = score
				best = enemy
	return best

func _finish(success: bool, reason: String) -> void:
	if state == "finished":
		return
	state = "finished"
	battle_started = false
	var summary := {
		"success": success,
		"reason": reason,
		"leader_id": leader_id,
		"leader_name": GameDataScript.CELLS[leader_id]["name"],
		"base_hp": int(round(base_hp)),
		"elapsed": elapsed,
		"wave": wave_index + 1,
		"defeated": defeated_count,
		"learning": GameDataScript.RESULT_COPY[leader_id]
	}
	emit_signal("battle_finished", summary)

func _update_hud() -> void:
	hp_label.text = "체력 " + str(int(round(base_hp)))
	wave_label.text = "웨이브 " + str(wave_index + 1) + "/" + str(GameDataScript.WAVES.size())
	top_label.text = _format_time(elapsed)

	var data: Dictionary = GameDataScript.CELLS[leader_id]
	if skill_cooldown <= 0.0:
		skill_button.text = data["skill_name"]
		skill_button.disabled = false
	else:
		skill_button.text = data["skill_name"] + " " + str(ceil(skill_cooldown)) + "초"
		skill_button.disabled = true
	cooldown_bar.value = 1.0 - skill_cooldown / max(skill_max_cooldown, 0.01)

func _prune_units() -> void:
	var alive_enemies := []
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.alive:
			alive_enemies.append(enemy)
	enemies = alive_enemies

func _lane_y(size: Vector2, lane: int) -> float:
	return lerp(210.0, size.y - 246.0, float(lane) / 2.0)

func _format_time(seconds: float) -> String:
	var total := int(floor(seconds))
	return "%02d:%02d" % [total / 60, total % 60]

func _metric_label(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.clip_text = true
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.custom_minimum_size = Vector2(0.0, 28.0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 15)
	label.modulate = Color("#F7FFF9")
	return label

func _panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style
