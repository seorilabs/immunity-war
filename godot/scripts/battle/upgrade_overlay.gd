class_name UpgradeOverlay
extends Control
## 웨이브 간 강화 3택 오버레이. 선택 필수 — back으로 닫히지 않는다 (SCR-005).

signal picked(index: int)

var _options: Array[UpgradeDef] = []

func configure(options: Array[UpgradeDef]) -> void:
	_options = options

func _ready() -> void:
	var viewport_size := get_viewport_rect().size
	var dim := ColorRect.new()
	dim.color = Color(0.0, 0.05, 0.05, 0.72)
	add_child(dim)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.position = Vector2.ZERO
	dim.size = viewport_size

	var margin_container := MarginContainer.new()
	add_child(margin_container)
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.position = Vector2.ZERO
	margin_container.size = viewport_size
	for side in ["margin_left", "margin_right"]:
		margin_container.add_theme_constant_override(side, 24)
	margin_container.add_theme_constant_override("margin_top", 140)
	margin_container.add_theme_constant_override("margin_bottom", 160)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	margin_container.add_child(box)

	var title := UiStyle.label("부대 강화", 28, UiStyle.TEXT_PRIMARY, HORIZONTAL_ALIGNMENT_CENTER)
	title.custom_minimum_size = Vector2(0.0, 40.0)
	box.add_child(title)
	var sub := UiStyle.label("다음 웨이브 전에 하나를 선택하세요", 15, UiStyle.TEXT_SUB, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(sub)

	for i in range(_options.size()):
		box.add_child(_option_card(i, _options[i]))

func _option_card(index: int, upgrade: UpgradeDef) -> Control:
	var is_rare := upgrade.rarity == UpgradeDef.Rarity.RARE
	var border := Color("#FFD966") if is_rare else UiStyle.ACTION_PRIMARY
	var card := Button.new()
	card.custom_minimum_size = Vector2(0.0, 88.0)
	card.add_theme_stylebox_override("normal", UiStyle.panel_style(Color(0.04, 0.16, 0.15, 0.96), border))
	card.add_theme_stylebox_override("hover", UiStyle.panel_style(Color(0.06, 0.2, 0.19, 0.96), border))
	card.add_theme_stylebox_override("pressed", UiStyle.panel_style(Color(0.03, 0.12, 0.11, 0.96), border))
	card.pressed.connect(func() -> void: picked.emit(index))

	var card_width := get_viewport_rect().size.x - 48.0
	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	card.add_child(box)
	box.position = Vector2(14.0, 12.0)
	box.size = Vector2(card_width - 28.0, 64.0)

	var name_text := upgrade.display_name + ("  [희귀]" if is_rare else "")
	var name_label := UiStyle.label(name_text, 19, Color("#FFD966") if is_rare else UiStyle.TEXT_PRIMARY)
	name_label.custom_minimum_size = Vector2(0.0, 28.0)
	box.add_child(name_label)
	var desc := UiStyle.label(upgrade.description, 14, UiStyle.TEXT_SUB)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc.custom_minimum_size = Vector2(0.0, 36.0)
	box.add_child(desc)
	return card
