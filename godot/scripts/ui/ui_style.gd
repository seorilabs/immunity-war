class_name UiStyle
## 코드 생성 UI에서 쓰는 공용 팔레트·스타일 헬퍼. 토큰 값의 원천은 03-ui-ux-spec 디자인 시스템 표.

const BG_DEEP := Color("#061615")
const BG_ALT := Color("#071716")
const TEXT_PRIMARY := Color("#F7FFF9")
const TEXT_SUB := Color("#D8FFF2")
const ACTION_PRIMARY := Color("#20C7A6")
const ACTION_PRIMARY_FG := Color("#062320")
const SUCCESS := Color("#B6FFE9")
const DANGER := Color("#FFC3B8")

static func panel_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	return style

static func button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(8)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

static func colored_button(text: String, bg: Color, fg: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0.0, 54.0)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", fg)
	button.add_theme_stylebox_override("normal", button_style(bg))
	button.add_theme_stylebox_override("hover", button_style(bg.lerp(Color.WHITE, 0.08)))
	button.add_theme_stylebox_override("pressed", button_style(bg.darkened(0.12)))
	button.add_theme_stylebox_override("disabled", button_style(Color("#33504C")))
	return button

static func label(text: String, size: int, color: Color, alignment: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.clip_text = true
	lbl.horizontal_alignment = alignment
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.add_theme_font_size_override("font_size", size)
	lbl.modulate = color
	return lbl
