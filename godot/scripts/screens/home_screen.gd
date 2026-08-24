extends ScreenBase

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_add_background(UiStyle.BG_DEEP)

	var content := _screen_container(18)

	var top_row := HBoxContainer.new()
	content.add_child(top_row)
	var title := UiStyle.label("면역 전쟁", 40, UiStyle.TEXT_PRIMARY)
	title.custom_minimum_size = Vector2(0.0, 56.0)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_row.add_child(title)
	top_row.add_child(_currency_chip())

	var subtitle := UiStyle.label("면역 세포 부대를 이끌어 몸속 경계로 밀려오는 박테리아를 막아내세요.", 18, UiStyle.TEXT_SUB)
	subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle.custom_minimum_size = Vector2(0.0, 58.0)
	content.add_child(subtitle)

	var preview := BiomotionCanvas.new()
	preview.mode = "preview"
	preview.custom_minimum_size = Vector2(0.0, 372.0)
	content.add_child(preview)

	var badges := HBoxContainer.new()
	badges.add_theme_constant_override("separation", 8)
	content.add_child(badges)
	for text in ["전략 오토배틀", "로그라이트 강화", "면역 모티브"]:
		badges.add_child(_badge(text))

	content.add_child(_expanding_spacer())

	if GameState.has_run():
		var resume_button := UiStyle.colored_button("이어하기 — " + String(GameState.run_stage_id()), UiStyle.ACTION_PRIMARY, UiStyle.ACTION_PRIMARY_FG)
		resume_button.pressed.connect(func() -> void: go(&"battle", {"stage": GameState.run_stage_id(), "restore": true}))
		content.add_child(resume_button)

	var next_stage := GameState.next_stage()
	var start_style := Color("#173D39") if GameState.has_run() else UiStyle.ACTION_PRIMARY
	var start_fg := UiStyle.TEXT_PRIMARY if GameState.has_run() else UiStyle.ACTION_PRIMARY_FG
	var start_button := UiStyle.colored_button("전투 시작 — " + next_stage.display_name, start_style, start_fg)
	start_button.pressed.connect(func() -> void: go(&"stage_select"))
	content.add_child(start_button)

	var guide_button := UiStyle.colored_button("세포 도감", Color("#173D39"), UiStyle.TEXT_PRIMARY)
	guide_button.pressed.connect(func() -> void: go(&"guide"))
	content.add_child(guide_button)

func _currency_chip() -> Control:
	var chip := UiStyle.label("사이토카인 " + str(GameState.currency()), 15, Color("#FFD966"), HORIZONTAL_ALIGNMENT_CENTER)
	chip.custom_minimum_size = Vector2(120.0, 34.0)
	chip.add_theme_stylebox_override("normal", UiStyle.panel_style(Color(0.09, 0.23, 0.21, 0.9), Color(1.0, 0.85, 0.4, 0.35)))
	return chip
