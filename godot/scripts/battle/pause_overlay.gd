class_name PauseOverlay
extends Control
## 전투 일시정지 오버레이 (03-ui-ux-spec.md:136). 계속 / 포기 두 선택만 제공하고 포기는 실패 처리를 명시한다.

signal resume_pressed
signal give_up_pressed

const GIVE_UP_NOTICE := "포기하면 이번 전투는 실패로 기록됩니다."

## 부모가 add_child 전에 전체 화면 앵커를 지정한 뒤 호출한다.
func setup() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.08, 0.08, 0.72)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", UiStyle.panel_style(Color(0.03, 0.13, 0.12, 0.96), Color(0.55, 1.0, 0.82, 0.24)))
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.anchor_left = 0.0
	panel.anchor_right = 1.0
	panel.offset_left = 24.0
	panel.offset_right = -24.0
	panel.offset_top = -122.0
	panel.offset_bottom = 122.0
	add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)

	var title := UiStyle.label("일시정지", 22, UiStyle.TEXT_PRIMARY, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(title)

	var notice := UiStyle.label(GIVE_UP_NOTICE, 14, UiStyle.DANGER, HORIZONTAL_ALIGNMENT_CENTER)
	notice.clip_text = false
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(notice)

	var resume_button := UiStyle.colored_button("계속", UiStyle.ACTION_PRIMARY, UiStyle.ACTION_PRIMARY_FG)
	resume_button.pressed.connect(func() -> void: resume_pressed.emit())
	box.add_child(resume_button)

	var give_up_button := Button.new()
	give_up_button.text = "포기"
	give_up_button.custom_minimum_size = Vector2(0.0, 54.0)
	give_up_button.add_theme_color_override("font_color", UiStyle.DANGER)
	give_up_button.pressed.connect(func() -> void: give_up_pressed.emit())
	box.add_child(give_up_button)
