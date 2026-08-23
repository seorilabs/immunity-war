class_name ScreenBase
extends Control
## 모든 화면 씬의 베이스. 라우터가 setup으로 인자를 넘기고 navigate 시그널로 전환을 받는다.
## 코드 생성 UI 화면들이 공유하는 배경/컨테이너/배지 헬퍼를 제공한다.

signal navigate(target: StringName, args: Dictionary)

func setup(_args: Dictionary) -> void:
	pass

func go(target: StringName, args: Dictionary = {}) -> void:
	navigate.emit(target, args)

func _add_background(color: Color) -> void:
	var bg := ColorRect.new()
	bg.color = color
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

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

func _badge(text: String) -> Label:
	var label := UiStyle.label(text, 13, UiStyle.TEXT_SUB, HORIZONTAL_ALIGNMENT_CENTER)
	label.custom_minimum_size = Vector2(100.0, 30.0)
	label.add_theme_stylebox_override("normal", UiStyle.panel_style(Color(0.09, 0.23, 0.21, 0.9), Color(0.55, 1.0, 0.82, 0.2)))
	return label

func _expanding_spacer() -> Control:
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	return spacer
