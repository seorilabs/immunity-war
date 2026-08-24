extends ScreenBase
## 출격 준비: 리더 선택 + 세포 레벨업. 보유 세포가 4 이하인 동안 동료는 자동 편성된다.

var _stage_id: StringName
var _content: VBoxContainer

func setup(args: Dictionary) -> void:
	_stage_id = args.get("stage", GameState.next_stage().id)

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_rebuild()

func _rebuild() -> void:
	for child in get_children():
		child.queue_free()
	_add_background(UiStyle.BG_ALT)
	_content = _screen_container(16)

	var stage_def := Db.stage(_stage_id)
	var header_row := HBoxContainer.new()
	_content.add_child(header_row)
	var header := UiStyle.label("출격 준비 — " + stage_def.display_name, 24, UiStyle.TEXT_PRIMARY)
	header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(header)
	header_row.add_child(UiStyle.label("사이토카인 " + str(GameState.currency()), 15, Color("#FFD966")))

	var tags_row := HBoxContainer.new()
	tags_row.add_theme_constant_override("separation", 8)
	_content.add_child(tags_row)
	tags_row.add_child(UiStyle.label("등장 적:", 14, UiStyle.TEXT_SUB))
	for tag in _stage_enemy_tags(stage_def):
		tags_row.add_child(_badge(_tag_name(tag)))

	var hint := UiStyle.label("카드를 탭해 리더를 선택하세요. 나머지 세포는 동료로 자동 편성됩니다.", 14, UiStyle.TEXT_SUB)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_content.add_child(hint)

	var leader_id := GameState.deck_leader()
	for cell_id in GameState.unlocked_cell_ids():
		_content.add_child(_cell_row(Db.cell(cell_id), cell_id == leader_id))

	_content.add_child(_expanding_spacer())

	var launch := UiStyle.colored_button("출격", UiStyle.ACTION_PRIMARY, UiStyle.ACTION_PRIMARY_FG)
	launch.pressed.connect(_launch)
	_content.add_child(launch)

	var back := UiStyle.colored_button("맵으로", Color("#173D39"), UiStyle.TEXT_PRIMARY)
	back.pressed.connect(func() -> void: go(&"stage_select"))
	_content.add_child(back)

func _cell_row(def: CellDef, is_leader: bool) -> Control:
	var level := GameState.cell_level(def.id)
	var border := def.color if is_leader else Color(def.color, 0.35)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0.0, 108.0)
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.03, 0.14, 0.13, 0.92), border))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)

	var text_box := VBoxContainer.new()
	text_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_box.add_theme_constant_override("separation", 4)
	row.add_child(text_box)

	var name_text := ("리더 · " if is_leader else "") + def.display_name + "  Lv.%d" % level
	text_box.add_child(UiStyle.label(name_text, 18, def.accent if is_leader else UiStyle.TEXT_PRIMARY))
	text_box.add_child(UiStyle.label(def.role + " · " + def.skill.display_name, 14, UiStyle.TEXT_SUB))
	var stats := UiStyle.label("공격 %.1f · 사거리 %d" % [def.damage * CombatRules.level_mult(level), int(def.attack_range)], 13, UiStyle.TEXT_SUB)
	text_box.add_child(stats)

	var button_box := VBoxContainer.new()
	button_box.add_theme_constant_override("separation", 6)
	row.add_child(button_box)

	if not is_leader:
		var pick := UiStyle.colored_button("리더로", def.color, UiStyle.BG_DEEP)
		pick.custom_minimum_size = Vector2(96.0, 40.0)
		pick.add_theme_font_size_override("font_size", 14)
		pick.pressed.connect(func() -> void:
			GameState.set_deck_leader(def.id)
			_rebuild())
		button_box.add_child(pick)

	if level < Economy.LEVEL_MAX:
		var cost := Economy.level_up_cost(level)
		var level_up := UiStyle.colored_button("강화 %d" % cost, Color("#173D39"), UiStyle.TEXT_PRIMARY)
		level_up.custom_minimum_size = Vector2(96.0, 40.0)
		level_up.add_theme_font_size_override("font_size", 14)
		level_up.disabled = GameState.currency() < cost
		level_up.pressed.connect(func() -> void:
			if GameState.try_level_up(def.id):
				_rebuild())
		button_box.add_child(level_up)
	else:
		button_box.add_child(UiStyle.label("최대 레벨", 13, UiStyle.TEXT_SUB, HORIZONTAL_ALIGNMENT_CENTER))

	return panel

func _launch() -> void:
	var args := {"stage": _stage_id}
	if GameState.is_tutorial_done():
		go(&"battle", args)
	else:
		go(&"intro", args)

func _stage_enemy_tags(stage_def: StageDef) -> Array[StringName]:
	var tags: Array[StringName] = []
	for wave in stage_def.waves:
		for entry in wave.spawns:
			for tag in entry.enemy.tags:
				if not tags.has(tag):
					tags.append(tag)
	return tags

func _tag_name(tag: StringName) -> String:
	match tag:
		&"swarm":
			return "물량"
		&"armored":
			return "장갑"
		&"fast":
			return "쾌속"
		&"toxin":
			return "독소"
		&"biofilm":
			return "바이오필름"
		_:
			return String(tag)
