class_name BattleHud
extends Control
## 전투 HUD 표시 전용. 컨트롤러 상태를 시그널·update 호출로만 반영한다.

signal skill_pressed
signal retreat_pressed

var _hp_label: Label
var _wave_label: Label
var _time_label: Label
var _status_label: Label
var _skill_button: Button
var _cooldown_bar: ProgressBar

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	var top_panel := PanelContainer.new()
	top_panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.03, 0.12, 0.11, 0.82), Color(0.55, 1.0, 0.82, 0.18)))
	add_child(top_panel)
	top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 14.0
	top_panel.offset_top = 12.0
	top_panel.offset_right = -14.0
	top_panel.offset_bottom = 98.0

	var top_grid := GridContainer.new()
	top_grid.columns = 3
	top_grid.add_theme_constant_override("h_separation", 8)
	top_grid.add_theme_constant_override("v_separation", 4)
	top_panel.add_child(top_grid)

	_hp_label = _metric_label("체력 120")
	_wave_label = _metric_label("웨이브 1/3")
	_time_label = _metric_label("00:00")
	top_grid.add_child(_hp_label)
	top_grid.add_child(_wave_label)
	top_grid.add_child(_time_label)

	_status_label = UiStyle.label("면역 세포 배치 중", 14, UiStyle.TEXT_SUB, HORIZONTAL_ALIGNMENT_CENTER)
	_status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_grid.add_child(_status_label)
	top_grid.add_child(_metric_label(""))
	top_grid.add_child(_metric_label(""))

	var bottom_panel := PanelContainer.new()
	bottom_panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.03, 0.12, 0.11, 0.86), Color(0.55, 1.0, 0.82, 0.18)))
	add_child(bottom_panel)
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_left = 14.0
	bottom_panel.offset_right = -14.0
	bottom_panel.offset_top = -112.0
	bottom_panel.offset_bottom = -14.0

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 10)
	bottom_panel.add_child(action_row)

	var skill_box := VBoxContainer.new()
	skill_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_row.add_child(skill_box)

	_skill_button = Button.new()
	_skill_button.custom_minimum_size = Vector2(0.0, 54.0)
	_skill_button.pressed.connect(func() -> void: skill_pressed.emit())
	skill_box.add_child(_skill_button)

	_cooldown_bar = ProgressBar.new()
	_cooldown_bar.show_percentage = false
	_cooldown_bar.min_value = 0.0
	_cooldown_bar.max_value = 1.0
	_cooldown_bar.value = 1.0
	_cooldown_bar.custom_minimum_size = Vector2(0.0, 8.0)
	skill_box.add_child(_cooldown_bar)

	var retreat_button := Button.new()
	retreat_button.text = "철수"
	retreat_button.custom_minimum_size = Vector2(74.0, 54.0)
	retreat_button.pressed.connect(func() -> void: retreat_pressed.emit())
	action_row.add_child(retreat_button)

func update_hud(base_hp: float, wave_index: int, wave_total: int, elapsed: float) -> void:
	_hp_label.text = "체력 " + str(int(round(base_hp)))
	_wave_label.text = "웨이브 %d/%d" % [wave_index + 1, wave_total]
	_time_label.text = _format_time(elapsed)

func update_skill(skill_name: String, cooldown: float, max_cooldown: float) -> void:
	if cooldown <= 0.0:
		_skill_button.text = skill_name
		_skill_button.disabled = false
	else:
		_skill_button.text = "%s %d초" % [skill_name, int(ceil(cooldown))]
		_skill_button.disabled = true
	_cooldown_bar.value = 1.0 - cooldown / maxf(max_cooldown, 0.01)

func set_status(text: String) -> void:
	_status_label.text = text

func _metric_label(text: String) -> Label:
	var label := UiStyle.label(text, 15, UiStyle.TEXT_PRIMARY, HORIZONTAL_ALIGNMENT_CENTER)
	label.custom_minimum_size = Vector2(0.0, 28.0)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label

func _format_time(seconds: float) -> String:
	var total := int(floor(seconds))
	@warning_ignore("integer_division")
	return "%02d:%02d" % [total / 60, total % 60]
