extends ScreenBase

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_add_background(UiStyle.BG_ALT)
	var content := _screen_container(16)

	var header := UiStyle.label("리더 세포 선택", 30, UiStyle.TEXT_PRIMARY)
	header.custom_minimum_size = Vector2(0.0, 44.0)
	content.add_child(header)
	var sub := UiStyle.label("AI 동료 2개가 함께 전투에 참여합니다. 리더 스킬만 직접 사용합니다.", 15, UiStyle.TEXT_SUB)
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.custom_minimum_size = Vector2(0.0, 54.0)
	content.add_child(sub)

	for cell_id in Db.cell_order:
		content.add_child(_cell_card(Db.cell(cell_id)))

	content.add_child(_expanding_spacer())

	var back_button := UiStyle.colored_button("처음으로", Color("#173D39"), UiStyle.TEXT_PRIMARY)
	back_button.pressed.connect(func() -> void: go(&"home"))
	content.add_child(back_button)

func _cell_card(def: CellDef) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, 142.0)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.03, 0.14, 0.13, 0.9), def.color))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var icon := BiomotionCanvas.new()
	icon.mode = "card"
	icon.custom_minimum_size = Vector2(74.0, 94.0)
	row.add_child(icon)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)

	text_box.add_child(UiStyle.label(def.display_name + " · " + def.role, 19, UiStyle.TEXT_PRIMARY))
	var desc := UiStyle.label(def.description, 14, UiStyle.TEXT_SUB)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0.0, 42.0)
	text_box.add_child(desc)
	text_box.add_child(UiStyle.label(def.skill.display_name, 14, def.accent))

	var pick := UiStyle.colored_button("선택", def.color, UiStyle.BG_DEEP)
	pick.custom_minimum_size = Vector2(76.0, 48.0)
	pick.pressed.connect(func() -> void: _start_battle(def.id))
	row.add_child(pick)

	return panel

func _start_battle(cell_id: StringName) -> void:
	GameState.selected_leader = cell_id
	go(&"battle", {"leader": cell_id, "stage": GameState.current_stage_id})
