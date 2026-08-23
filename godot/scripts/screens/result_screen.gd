extends ScreenBase

var _summary: Dictionary = {}

func setup(args: Dictionary) -> void:
	_summary = args.get("summary", GameState.last_summary)

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_add_background(UiStyle.BG_DEEP)
	var content := _screen_container(18)

	var success: bool = _summary.get("success", false)
	var title_text := "방어 성공" if success else "방어 실패"
	var title_color := UiStyle.SUCCESS if success else UiStyle.DANGER
	content.add_child(UiStyle.label(title_text, 36, title_color))

	var result_box := PanelContainer.new()
	result_box.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.03, 0.14, 0.13, 0.88), Color(0.55, 1.0, 0.82, 0.22)))
	content.add_child(result_box)
	var rows := VBoxContainer.new()
	rows.add_theme_constant_override("separation", 8)
	result_box.add_child(rows)
	rows.add_child(UiStyle.label("리더: " + str(_summary.get("leader_name", "")), 18, UiStyle.TEXT_PRIMARY))
	rows.add_child(UiStyle.label("남은 체력: %s / 처치: %s" % [str(_summary.get("base_hp", 0)), str(_summary.get("defeated", 0))], 17, UiStyle.TEXT_SUB))
	rows.add_child(UiStyle.label("전투 시간: %s / 도달 웨이브: %s" % [_format_time(float(_summary.get("elapsed", 0.0))), str(_summary.get("wave", 0))], 17, UiStyle.TEXT_SUB))

	var learning := UiStyle.label(str(_summary.get("learning", "")), 17, UiStyle.TEXT_PRIMARY)
	learning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	learning.custom_minimum_size = Vector2(0.0, 108.0)
	content.add_child(learning)

	content.add_child(_expanding_spacer())

	var retry := UiStyle.colored_button("다시 하기", UiStyle.ACTION_PRIMARY, UiStyle.ACTION_PRIMARY_FG)
	retry.pressed.connect(func() -> void: go(&"cell_select"))
	content.add_child(retry)

	var home := UiStyle.colored_button("처음으로", Color("#173D39"), UiStyle.TEXT_PRIMARY)
	home.pressed.connect(func() -> void: go(&"home"))
	content.add_child(home)

func _format_time(seconds: float) -> String:
	var total := int(floor(seconds))
	@warning_ignore("integer_division")
	return "%02d:%02d" % [total / 60, total % 60]
