extends ScreenBase

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_add_background(UiStyle.BG_ALT)
	var content := _screen_container(16)

	var header := UiStyle.label("감염 지도 — " + Db.chapter_list[0].display_name, 28, UiStyle.TEXT_PRIMARY)
	header.custom_minimum_size = Vector2(0.0, 44.0)
	content.add_child(header)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	content.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)

	var current := GameState.next_stage()
	for stage_def in Db.stage_sequence():
		list.add_child(_stage_row(stage_def, current))

	var back_button := UiStyle.colored_button("홈으로", Color("#173D39"), UiStyle.TEXT_PRIMARY)
	back_button.pressed.connect(func() -> void: go(&"home"))
	content.add_child(back_button)

func _stage_row(stage_def: StageDef, current: StageDef) -> Control:
	var cleared := GameState.is_stage_cleared(stage_def.id)
	var unlocked := GameState.is_stage_unlocked(stage_def)
	var is_current := stage_def.id == current.id

	var border := UiStyle.ACTION_PRIMARY if is_current else (Color(0.55, 1.0, 0.82, 0.25) if cleared else Color(0.3, 0.4, 0.38, 0.4))
	var row := Button.new()
	row.custom_minimum_size = Vector2(0.0, 64.0)
	row.disabled = not unlocked
	row.add_theme_stylebox_override("normal", UiStyle.panel_style(Color(0.04, 0.15, 0.14, 0.92), border))
	row.add_theme_stylebox_override("hover", UiStyle.panel_style(Color(0.06, 0.19, 0.18, 0.92), border))
	row.add_theme_stylebox_override("pressed", UiStyle.panel_style(Color(0.03, 0.12, 0.11, 0.92), border))
	row.add_theme_stylebox_override("disabled", UiStyle.panel_style(Color(0.03, 0.1, 0.1, 0.7), Color(0.2, 0.28, 0.27, 0.4)))
	row.pressed.connect(func() -> void: go(&"deck", {"stage": stage_def.id}))

	var row_width := get_viewport_rect().size.x - 32.0

	var name_label := UiStyle.label("%s  %s" % [stage_def.id, stage_def.display_name], 18, UiStyle.TEXT_PRIMARY if unlocked else UiStyle.TEXT_SUB)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(name_label)
	name_label.position = Vector2(16.0, 0.0)
	name_label.size = Vector2(row_width - 110.0, 64.0)

	var state_text := "출격" if is_current else ("클리어" if cleared else "잠김")
	var state_color := UiStyle.ACTION_PRIMARY if is_current else (UiStyle.SUCCESS if cleared else UiStyle.TEXT_SUB)
	var state_label := UiStyle.label(state_text, 15, state_color, HORIZONTAL_ALIGNMENT_RIGHT)
	state_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(state_label)
	state_label.position = Vector2(row_width - 94.0, 0.0)
	state_label.size = Vector2(78.0, 64.0)
	return row
