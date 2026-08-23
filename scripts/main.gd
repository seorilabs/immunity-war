extends Control

const GameDataScript := preload("res://scripts/game_data.gd")
const BattleDirectorScript := preload("res://scripts/battle_director.gd")
const BiomotionCanvasScript := preload("res://scripts/biomotion_canvas.gd")

var selected_cell_id := "macrophage"
var app_theme: Theme

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_setup_theme()
	_show_boot()

func _setup_theme() -> void:
	app_theme = Theme.new()
	var font: Font = null
	if ResourceLoader.exists("res://assets/fonts/NotoSansKR-wght.ttf"):
		font = load("res://assets/fonts/NotoSansKR-wght.ttf")
	if font == null:
		var system_font := SystemFont.new()
		system_font.font_names = PackedStringArray(["Apple SD Gothic Neo", "Noto Sans KR", "Noto Sans CJK KR", "sans-serif"])
		font = system_font
	app_theme.default_font = font
	app_theme.default_font_size = 17
	theme = app_theme

func _clear_screen() -> void:
	for child in get_children():
		child.queue_free()

func _show_boot() -> void:
	_clear_screen()
	_add_background(Color("#061615"))

	var content := _screen_container(18)

	var title := _label("면역 전쟁", 40, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT)
	title.custom_minimum_size = Vector2(0.0, 56.0)
	content.add_child(title)

	var subtitle := _label("면역 세포가 되어 몸속 경계로 밀려오는 박테리아를 막아내세요.", 18, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_LEFT)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.custom_minimum_size = Vector2(0.0, 58.0)
	content.add_child(subtitle)

	var preview := BiomotionCanvasScript.new()
	preview.mode = "preview"
	preview.custom_minimum_size = Vector2(0.0, 392.0)
	content.add_child(preview)

	var badges := HBoxContainer.new()
	badges.add_theme_constant_override("separation", 8)
	content.add_child(badges)
	for text in ["자동 전투", "3웨이브", "면역 모티브"]:
		badges.add_child(_badge(text))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	var start_button := _button("전투 시작", Color("#20C7A6"), Color("#062320"))
	start_button.pressed.connect(_show_intro)
	content.add_child(start_button)

	var guide_button := _button("세포 도감", Color("#173D39"), Color("#F7FFF9"))
	guide_button.pressed.connect(_show_guide)
	content.add_child(guide_button)

func _show_intro() -> void:
	_clear_screen()
	_add_background(Color("#061615"))

	var canvas := BiomotionCanvasScript.new()
	canvas.mode = "intro"
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(canvas)

	var overlay := _screen_container(20)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	var spacer_top := Control.new()
	spacer_top.custom_minimum_size = Vector2(0.0, 80.0)
	overlay.add_child(spacer_top)
	overlay.add_child(_label("침투 감지", 34, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT))
	var copy := _label("박테리아 군집이 조직 경계로 접근합니다.", 18, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_LEFT)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay.add_child(copy)

	await get_tree().create_timer(1.9).timeout
	_show_cell_select()

func _show_cell_select() -> void:
	_clear_screen()
	_add_background(Color("#071716"))
	var content := _screen_container(16)

	var header := _label("리더 세포 선택", 30, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT)
	header.custom_minimum_size = Vector2(0.0, 44.0)
	content.add_child(header)
	var sub := _label("AI 동료 2개가 함께 전투에 참여합니다. 리더 스킬만 직접 사용합니다.", 15, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_LEFT)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(0.0, 54.0)
	content.add_child(sub)

	for cell_id in ["macrophage", "neutrophil", "b_cell"]:
		content.add_child(_cell_card(cell_id))

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	var back_button := _button("처음으로", Color("#173D39"), Color("#F7FFF9"))
	back_button.pressed.connect(_show_boot)
	content.add_child(back_button)

func _start_battle(cell_id: String) -> void:
	selected_cell_id = cell_id
	_clear_screen()
	var battle := BattleDirectorScript.new()
	battle.battle_finished.connect(_show_result)
	add_child(battle)
	battle.start(cell_id)

func _show_result(summary: Dictionary) -> void:
	_clear_screen()
	_add_background(Color("#061615"))
	var content := _screen_container(18)

	var success: bool = summary["success"]
	var title_text := "방어 성공" if success else "방어 실패"
	var title_color := Color("#B6FFE9") if success else Color("#FFC3B8")
	content.add_child(_label(title_text, 36, title_color, HORIZONTAL_ALIGNMENT_LEFT))

	var result_box := PanelContainer.new()
	result_box.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.14, 0.13, 0.88), Color(0.55, 1.0, 0.82, 0.22)))
	content.add_child(result_box)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	result_box.add_child(rows)
	rows.add_child(_label("리더: " + String(summary["leader_name"]), 18, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT))
	rows.add_child(_label("남은 체력: " + str(summary["base_hp"]) + " / 처치: " + str(summary["defeated"]), 17, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_LEFT))
	rows.add_child(_label("전투 시간: " + _format_time(summary["elapsed"]) + " / 도달 웨이브: " + str(summary["wave"]), 17, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_LEFT))

	var learning := _label(String(summary["learning"]), 17, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT)
	learning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	learning.custom_minimum_size = Vector2(0.0, 108.0)
	content.add_child(learning)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	var retry := _button("다시 하기", Color("#20C7A6"), Color("#062320"))
	retry.pressed.connect(_show_cell_select)
	content.add_child(retry)

	var home := _button("처음으로", Color("#173D39"), Color("#F7FFF9"))
	home.pressed.connect(_show_boot)
	content.add_child(home)

func _show_guide() -> void:
	_clear_screen()
	_add_background(Color("#071716"))
	var content := _screen_container(16)
	content.add_child(_label("세포 도감", 30, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT))

	for cell_id in ["macrophage", "neutrophil", "b_cell"]:
		var data: Dictionary = GameDataScript.CELLS[cell_id]
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.14, 0.13, 0.86), data["color"]))
		content.add_child(panel)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 4)
		panel.add_child(box)
		box.add_child(_label(data["name"] + " · " + data["role"], 19, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT))
		var desc := _label(data["desc"], 15, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_LEFT)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(desc)
		var skill := _label(data["skill_name"] + ": " + data["skill_desc"], 15, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT)
		skill.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(skill)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(spacer)

	var back := _button("돌아가기", Color("#20C7A6"), Color("#062320"))
	back.pressed.connect(_show_boot)
	content.add_child(back)

func _cell_card(cell_id: String) -> Control:
	var data: Dictionary = GameDataScript.CELLS[cell_id]
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, 142.0)
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.03, 0.14, 0.13, 0.9), data["color"]))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var icon := BiomotionCanvasScript.new()
	icon.mode = "card"
	icon.custom_minimum_size = Vector2(74.0, 94.0)
	row.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)

	text_box.add_child(_label(data["name"] + " · " + data["role"], 19, Color("#F7FFF9"), HORIZONTAL_ALIGNMENT_LEFT))
	var desc := _label(data["desc"], 14, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_LEFT)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0.0, 42.0)
	text_box.add_child(desc)
	var skill := _label(data["skill_name"], 14, data["accent"], HORIZONTAL_ALIGNMENT_LEFT)
	text_box.add_child(skill)

	var pick := _button("선택", data["color"], Color("#061615"))
	pick.custom_minimum_size = Vector2(76.0, 48.0)
	pick.pressed.connect(func() -> void: _start_battle(cell_id))
	row.add_child(pick)

	return panel

func _screen_container(margin: int) -> VBoxContainer:
	var margin_container := MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)
	add_child(margin_container)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	margin_container.add_child(box)
	return box

func _add_background(color: Color) -> void:
	var bg := ColorRect.new()
	bg.color = color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

func _label(text: String, size: int, color: Color, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.text = text
	label.clip_text = true
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", size)
	label.modulate = color
	return label

func _button(text: String, bg: Color, fg: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 54.0)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", fg)
	button.add_theme_stylebox_override("normal", _button_style(bg))
	button.add_theme_stylebox_override("hover", _button_style(bg.lerp(Color.WHITE, 0.08)))
	button.add_theme_stylebox_override("pressed", _button_style(bg.darkened(0.12)))
	button.add_theme_stylebox_override("disabled", _button_style(Color("#33504C")))
	return button

func _badge(text: String) -> Label:
	var label := _label(text, 13, Color("#D8FFF2"), HORIZONTAL_ALIGNMENT_CENTER)
	label.custom_minimum_size = Vector2(100.0, 30.0)
	label.add_theme_stylebox_override("normal", _panel_style(Color(0.09, 0.23, 0.21, 0.9), Color(0.55, 1.0, 0.82, 0.2)))
	return label

func _button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

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

func _format_time(seconds: float) -> String:
	var total := int(floor(seconds))
	return "%02d:%02d" % [total / 60, total % 60]
