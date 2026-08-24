extends RefCounted
## 전투 화면 배선 검증: 증원 버튼이 게이지 상태를 매 프레임 반영하고, 탭이 실제 증원으로 이어지는지.
## 규격 출처: docs/game-design/03-ui-ux-spec.md:135·145, docs/game-design/02-gdd.md:109 (CON-003).

const BattleSceneRes := preload("res://scenes/battle/battle_scene.tscn")
const EPSILON := 0.0001

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

	var button := _find_button(scene, "증원")
	var bar := _find_reinforce_bar(scene)
	if button == null:
		failures.append("하단 액션 행에 증원 버튼이 없음")
		_teardown(host, scene)
		return failures
	if bar == null:
		failures.append("증원 게이지 진행 바가 없음")
	if button.custom_minimum_size.x < 64.0 and button.custom_minimum_size.y < 64.0:
		failures.append("증원 버튼이 64dp 미만: %s" % str(button.custom_minimum_size))

	# 미충전: 비활성 + 충전률 표시
	controller.reinforce_gauge = 96.0
	scene._process(0.0)
	if not button.disabled:
		failures.append("게이지 96에서 증원 버튼이 활성")
	if button.text != "증원 96%":
		failures.append("증원 버튼 충전률 표시 이상: %s" % button.text)
	if bar != null and absf(float(bar.value) - 0.96) > EPSILON:
		failures.append("게이지 바 값 불일치: %s" % str(bar.value))

	# 가득 참: 활성 + 라벨 전환
	controller.reinforce_gauge = BattleController.REINFORCE_MAX
	scene._process(0.0)
	if button.disabled:
		failures.append("게이지 100에서 증원 버튼이 비활성")
	if button.text != "증원 투입":
		failures.append("증원 가능 라벨 이상: %s" % button.text)
	if bar != null and absf(float(bar.value) - 1.0) > EPSILON:
		failures.append("가득 찬 게이지 바 값 불일치: %s" % str(bar.value))

	# 탭 → 실제 증원 투입
	var cells_before := controller.registry.cells.size()
	button.pressed.emit()
	if not is_equal_approx(controller.reinforce_gauge, 0.0):
		failures.append("증원 버튼 탭이 게이지를 소모하지 않음: %s" % controller.reinforce_gauge)
	if controller.registry.cells.size() != cells_before + 1:
		failures.append("증원 버튼 탭이 임시 세포를 소환하지 않음")
	scene._process(0.0)
	if not button.disabled:
		failures.append("증원 직후 버튼이 다시 비활성화되지 않음")

	_teardown(host, scene)
	return failures

static func _find_button(node: Node, text_prefix: String) -> Button:
	var button := node as Button
	if button != null and button.text.begins_with(text_prefix):
		return button
	for child in node.get_children():
		var found := _find_button(child, text_prefix)
		if found != null:
			return found
	return null

## 증원 버튼과 같은 박스에 들어 있는 진행 바를 찾는다.
static func _find_reinforce_bar(scene: Node) -> ProgressBar:
	var button := _find_button(scene, "증원")
	if button == null or button.get_parent() == null:
		return null
	for sibling in button.get_parent().get_children():
		var bar := sibling as ProgressBar
		if bar != null:
			return bar
	return null

static func _teardown(host: Node, scene: Node) -> void:
	host.remove_child(scene)
	scene.queue_free()
