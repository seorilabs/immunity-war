extends RefCounted
## 일시정지 오버레이와 back 처리 검증.
## 규격 출처: docs/game-design/03-ui-ux-spec.md:34~36 (back / app resume), :136 (계속·포기 + 실패 처리 문구).

const BattleSceneRes := preload("res://scenes/battle/battle_scene.tscn")

static func run(host: Node) -> PackedStringArray:
	var failures := PackedStringArray()
	var scene: Control = BattleSceneRes.instantiate()
	scene.setup({"leader": &"macrophage", "stage": &"1-1"})
	host.add_child(scene)

	var controller: BattleController = scene._controller
	if controller == null:
		failures.append("전투 화면이 컨트롤러를 만들지 못함")
		_teardown(host, scene)
		return failures

	# 하단 액션 행: 일시정지 버튼이 있고 철수 직결 버튼은 없다.
	if _find_button(scene, "철수") != null:
		failures.append("철수 버튼이 남아 있음 (일시정지 오버레이로 이동해야 함)")
	if _find_button(scene, "일시") == null:
		failures.append("하단 액션 행에 일시정지 버튼이 없음")

	# back: 전투 중이면 오버레이를 연다
	if not scene.handle_back_request():
		failures.append("전투 중 back 이 소비되지 않음")
	if not controller.is_paused():
		failures.append("back 후 전투가 일시정지되지 않음 (state=%d)" % controller.state)
	var overlay := _find_overlay(scene)
	if overlay == null:
		failures.append("back 후 일시정지 오버레이가 없음")
	else:
		var texts := _label_texts(overlay)
		if not _contains(texts, PauseOverlay.GIVE_UP_NOTICE):
			failures.append("포기 실패 처리 문구가 없음: %s" % str(texts))
		if _find_button(overlay, "계속") == null:
			failures.append("오버레이에 계속 버튼이 없음")
		if _find_button(overlay, "포기") == null:
			failures.append("오버레이에 포기 버튼이 없음")
		if overlay.mouse_filter != Control.MOUSE_FILTER_STOP:
			failures.append("오버레이가 전투 입력을 가리지 않음")

	# 오버레이가 열린 상태의 back 은 오버레이만 닫는다
	if not scene.handle_back_request():
		failures.append("오버레이 표시 중 back 이 소비되지 않음")
	if controller.is_paused():
		failures.append("두 번째 back 후에도 일시정지가 유지됨")
	if _find_overlay(scene) != null:
		failures.append("두 번째 back 후에도 오버레이가 남아 있음")
	if controller.state != BattleController.State.RUNNING:
		failures.append("두 번째 back 후 RUNNING 복귀 실패 (state=%d)" % controller.state)

	# 앱이 백그라운드로 가면 자동 일시정지
	if not scene.handle_focus_out():
		failures.append("포커스 아웃이 일시정지를 걸지 못함")
	if not controller.is_paused():
		failures.append("포커스 아웃 후 일시정지 상태가 아님")

	# 계속 버튼 → 전투 재개
	var resume_button := _find_button(_find_overlay(scene), "계속")
	if resume_button == null:
		failures.append("포커스 아웃 오버레이에 계속 버튼이 없음")
	else:
		resume_button.pressed.emit()
		if controller.is_paused() or _find_overlay(scene) != null:
			failures.append("계속 버튼이 전투를 재개하지 못함")

	# 포기 버튼 → 실패로 종료
	scene.handle_back_request()
	var give_up_button := _find_button(_find_overlay(scene), "포기")
	if give_up_button == null:
		failures.append("오버레이에 포기 버튼이 없음 (2차)")
	else:
		give_up_button.pressed.emit()
		if controller.state != BattleController.State.FINISHED:
			failures.append("포기 버튼이 전투를 종료하지 못함 (state=%d)" % controller.state)

	# 종료 후 back 은 전투를 되살리지 않는다
	if scene.handle_back_request():
		failures.append("전투 종료 후 back 이 소비됨")
	if controller.state != BattleController.State.FINISHED:
		failures.append("전투 종료 후 back 이 상태를 되살림 (state=%d)" % controller.state)
	if _find_overlay(scene) != null:
		failures.append("전투 종료 후 일시정지 오버레이가 열림")

	_teardown(host, scene)
	return failures

static func _find_overlay(node: Node) -> PauseOverlay:
	if node == null:
		return null
	for child in node.get_children():
		var overlay := child as PauseOverlay
		if overlay != null and not overlay.is_queued_for_deletion():
			return overlay
	return null

static func _find_button(node: Node, text_prefix: String) -> Button:
	if node == null:
		return null
	var button := node as Button
	if button != null and button.text.begins_with(text_prefix):
		return button
	for child in node.get_children():
		var found := _find_button(child, text_prefix)
		if found != null:
			return found
	return null

static func _label_texts(node: Node) -> PackedStringArray:
	var texts := PackedStringArray()
	var label := node as Label
	if label != null:
		texts.append(label.text)
	for child in node.get_children():
		texts.append_array(_label_texts(child))
	return texts

static func _contains(texts: PackedStringArray, needle: String) -> bool:
	for text in texts:
		if text == needle:
			return true
	return false

static func _teardown(host: Node, scene: Node) -> void:
	host.remove_child(scene)
	scene.queue_free()
