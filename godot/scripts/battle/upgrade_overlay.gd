class_name UpgradeOverlay
extends Control
## SCR-005 강화 3택 오버레이. 표시 전용이며 선택 인덱스만 시그널로 올린다.
## 전장이 비치도록 반투명 딤 위에 카드를 얹고, 카드 열은 하단 엄지 존에 둔다.

signal choice_selected(index: int)

const COMMON_BORDER := Color("#20C7A6")
const RARE_BORDER := Color("#FFD166")
const CARD_HEIGHT := 88.0

## 부모가 add_child 전에 전체 화면 앵커를 지정한 뒤 호출한다.
func setup(choices: Array[UpgradeDef]) -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.08, 0.08, 0.66)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var title := UiStyle.label("다음 웨이브 전에 부대를 강화하세요", 16, UiStyle.TEXT_SUB, HORIZONTAL_ALIGNMENT_CENTER)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	title.offset_left = 14.0
	title.offset_right = -14.0
	title.offset_top = -CARD_HEIGHT * 3.0 - 92.0
	title.offset_bottom = -CARD_HEIGHT * 3.0 - 62.0
	add_child(title)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	column.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	column.offset_left = 14.0
	column.offset_right = -14.0
	column.offset_top = -CARD_HEIGHT * 3.0 - 56.0
	column.offset_bottom = -18.0
	add_child(column)

	for index in range(choices.size()):
		column.add_child(_card(choices[index], index))

func _card(upgrade: UpgradeDef, index: int) -> Button:
	var is_rare := upgrade.rarity == UpgradeDef.Rarity.RARE
	var border := RARE_BORDER if is_rare else COMMON_BORDER

	var button := Button.new()
	button.custom_minimum_size = Vector2(0.0, CARD_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_stylebox_override("normal", _card_style(border, 0.0))
	button.add_theme_stylebox_override("hover", _card_style(border, 0.06))
	button.add_theme_stylebox_override("pressed", _card_style(border, 0.14))
	button.add_theme_stylebox_override("focus", _card_style(border, 0.06))
	button.pressed.connect(func() -> void: choice_selected.emit(index))

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for side in ["margin_left", "margin_right"]:
		margin.add_theme_constant_override(side, 14)
	for side in ["margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 10)
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.add_child(margin)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	margin.add_child(box)

	var header := HBoxContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_IGNORE
	header.add_theme_constant_override("separation", 8)
	box.add_child(header)

	var name_label := UiStyle.label(upgrade.display_name, 18, UiStyle.TEXT_PRIMARY)
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(name_label)

	var badge := UiStyle.label("희귀" if is_rare else "일반", 13, border, HORIZONTAL_ALIGNMENT_RIGHT)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.custom_minimum_size = Vector2(46.0, 0.0)
	header.add_child(badge)

	var desc := UiStyle.label(upgrade.description, 14, UiStyle.TEXT_SUB)
	desc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc.clip_text = false
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(desc)

	return button

func _card_style(border: Color, lighten: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.13, 0.12, 0.94).lerp(Color.WHITE, lighten)
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(10)
	return style
