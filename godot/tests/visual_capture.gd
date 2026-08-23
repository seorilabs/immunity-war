extends Node

func _ready() -> void:
	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	add_child(main_scene.instantiate())
	await get_tree().create_timer(1.5).timeout
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png(OS.get_environment("CAPTURE_PATH"))
	get_tree().quit(0)
