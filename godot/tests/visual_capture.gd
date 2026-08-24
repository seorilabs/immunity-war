extends Node
## UI 검증용 스크린샷 캡처. 환경 변수:
##   CAPTURE_PATH   저장할 png 경로 (필수)
##   CAPTURE_SCREEN 라우터 화면 이름 (선택, 기본 home)
##   CAPTURE_DELAY  캡처 전 대기 초 (선택, 기본 1.5)
##   CAPTURE_CALL   대기 후 현재 화면에서 호출할 무인자 메서드 (선택, 예: handle_back_request)

func _ready() -> void:
	var main_scene: PackedScene = load(str(ProjectSettings.get_setting("application/run/main_scene")))
	var root := main_scene.instantiate()
	add_child(root)

	var target := OS.get_environment("CAPTURE_SCREEN")
	if not target.is_empty():
		root.call("goto", StringName(target))

	var delay := 1.5
	var delay_env := OS.get_environment("CAPTURE_DELAY")
	if not delay_env.is_empty():
		delay = float(delay_env)

	await get_tree().create_timer(delay).timeout

	var call_name := OS.get_environment("CAPTURE_CALL")
	if not call_name.is_empty():
		var screen: Node = root.get("_current")
		if screen != null and screen.has_method(call_name):
			screen.call(call_name)
			await get_tree().create_timer(0.4).timeout
		else:
			push_error("CAPTURE_CALL 대상 없음: %s" % call_name)

	var image: Image = get_viewport().get_texture().get_image()
	image.save_png(OS.get_environment("CAPTURE_PATH"))
	get_tree().quit(0)
