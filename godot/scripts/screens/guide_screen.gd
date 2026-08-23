extends ScreenBase

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_add_background(UiStyle.BG_ALT)
	var content := _screen_container(16)
	content.add_child(UiStyle.label("세포 도감", 30, UiStyle.TEXT_PRIMARY))

	for cell_id in Db.cell_order:
		var def := Db.cell(cell_id)
		var panel := PanelContainer.new()
		panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.03, 0.14, 0.13, 0.86), def.color))
		content.add_child(panel)
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 4)
		panel.add_child(box)
		box.add_child(UiStyle.label(def.display_name + " · " + def.role, 19, UiStyle.TEXT_PRIMARY))
		var desc := UiStyle.label(def.description, 15, UiStyle.TEXT_SUB)
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(desc)
		var skill := UiStyle.label(def.skill.display_name + ": " + def.skill.description, 15, UiStyle.TEXT_PRIMARY)
		skill.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(skill)

	content.add_child(_expanding_spacer())

	var back := UiStyle.colored_button("돌아가기", UiStyle.ACTION_PRIMARY, UiStyle.ACTION_PRIMARY_FG)
	back.pressed.connect(func() -> void: go(&"home"))
	content.add_child(back)
