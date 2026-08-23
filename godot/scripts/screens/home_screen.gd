extends ScreenBase

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_add_background(UiStyle.BG_DEEP)

	var content := _screen_container(18)

	var title := UiStyle.label("면역 전쟁", 40, UiStyle.TEXT_PRIMARY)
	title.custom_minimum_size = Vector2(0.0, 56.0)
	content.add_child(title)

	var subtitle := UiStyle.label("면역 세포가 되어 몸속 경계로 밀려오는 박테리아를 막아내세요.", 18, UiStyle.TEXT_SUB)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.custom_minimum_size = Vector2(0.0, 58.0)
	content.add_child(subtitle)

	var preview := BiomotionCanvas.new()
	preview.mode = "preview"
	preview.custom_minimum_size = Vector2(0.0, 392.0)
	content.add_child(preview)

	var badges := HBoxContainer.new()
	badges.add_theme_constant_override("separation", 8)
	content.add_child(badges)
	for text in ["자동 전투", "3웨이브", "면역 모티브"]:
		badges.add_child(_badge(text))

	content.add_child(_expanding_spacer())

	var start_button := UiStyle.colored_button("전투 시작", UiStyle.ACTION_PRIMARY, UiStyle.ACTION_PRIMARY_FG)
	start_button.pressed.connect(func() -> void: go(&"intro"))
	content.add_child(start_button)

	var guide_button := UiStyle.colored_button("세포 도감", Color("#173D39"), UiStyle.TEXT_PRIMARY)
	guide_button.pressed.connect(func() -> void: go(&"guide"))
	content.add_child(guide_button)
