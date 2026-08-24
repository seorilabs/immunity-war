extends ScreenBase

var _args: Dictionary = {}

func setup(args: Dictionary) -> void:
	_args = args

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_add_background(UiStyle.BG_DEEP)

	var canvas := BiomotionCanvas.new()
	canvas.mode = "intro"
	canvas.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(canvas)

	var overlay := _screen_container(20)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var spacer_top := Control.new()
	spacer_top.custom_minimum_size = Vector2(0.0, 80.0)
	overlay.add_child(spacer_top)
	overlay.add_child(UiStyle.label("침투 감지", 34, UiStyle.TEXT_PRIMARY))
	var copy := UiStyle.label("박테리아 군집이 조직 경계로 접근합니다.", 18, UiStyle.TEXT_SUB)
	copy.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay.add_child(copy)

	await get_tree().create_timer(1.9).timeout
	if is_inside_tree():
		go(&"battle", _args)
