extends Control
## main.tscn 루트. 화면 씬 전환을 소유한다 — 기존 main.gd의 clear_screen 패턴을 대체.

const SCREENS := {
	&"home": preload("res://scenes/screens/home_screen.tscn"),
	&"intro": preload("res://scenes/screens/intro_screen.tscn"),
	&"cell_select": preload("res://scenes/screens/cell_select_screen.tscn"),
	&"battle": preload("res://scenes/battle/battle_scene.tscn"),
	&"result": preload("res://scenes/screens/result_screen.tscn"),
	&"guide": preload("res://scenes/screens/guide_screen.tscn"),
}

var _current: ScreenBase

func _ready() -> void:
	goto(&"home")

func goto(target: StringName, args: Dictionary = {}) -> void:
	if not SCREENS.has(target):
		push_error("알 수 없는 화면: %s" % target)
		return
	if _current != null:
		_current.queue_free()
	var packed: PackedScene = SCREENS[target]
	var screen: ScreenBase = packed.instantiate()
	screen.navigate.connect(goto)
	screen.setup(args)
	_current = screen
	add_child(screen)
