extends RefCounted
## SCR-005 강화 3택 오버레이 구조 검증: 카드 3장, 하단 엄지 존 배치, 카드별 이름·설명·수치·rarity 표기.
## 규격 출처: docs/game-design/03-ui-ux-spec.md:152~160, 이슈 #5 인수조건.

const MIN_CARD_HEIGHT := 88.0

static func run(host: Node) -> PackedStringArray:
	var failures := PackedStringArray()
	var choices := UpgradePool.draw(1, 12345, [])
	if choices.size() != UpgradePool.CHOICE_COUNT:
		failures.append("오버레이 검증용 후보 추첨 실패: %d개" % choices.size())
		return failures

	var overlay := UpgradeOverlay.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.add_child(overlay)
	overlay.setup(choices)

	if overlay.mouse_filter != Control.MOUSE_FILTER_STOP:
		failures.append("오버레이가 전투 입력을 가리지 않음 (mouse_filter=%d)" % overlay.mouse_filter)

	var column := _find_column(overlay)
	if column == null:
		failures.append("카드 열(VBoxContainer)을 찾지 못함")
		_teardown(host, overlay)
		return failures

	# 하단 엄지 존: 아래 모서리에 앵커되고 화면 하단에서 위로 자란다.
	if not is_equal_approx(column.anchor_bottom, 1.0) or not is_equal_approx(column.anchor_top, 1.0):
		failures.append("카드 열이 하단 앵커가 아님 (top=%.2f bottom=%.2f)" % [column.anchor_top, column.anchor_bottom])
	if column.offset_bottom >= 0.0 or column.offset_top >= column.offset_bottom:
		failures.append("카드 열 오프셋이 하단 영역이 아님 (top=%.1f bottom=%.1f)" % [column.offset_top, column.offset_bottom])

	var cards: Array[Button] = []
	for child in column.get_children():
		var button := child as Button
		if button != null:
			cards.append(button)
	if cards.size() != choices.size():
		failures.append("카드 수 불일치: 후보 %d개 / 카드 %d개" % [choices.size(), cards.size()])

	var pressed: Array[int] = []
	overlay.choice_selected.connect(func(index: int) -> void: pressed.append(index))

	for i in range(cards.size()):
		var upgrade := choices[i]
		var texts := _label_texts(cards[i])
		if cards[i].custom_minimum_size.y < MIN_CARD_HEIGHT:
			failures.append("카드 높이 부족: %s (%.1f)" % [upgrade.id, cards[i].custom_minimum_size.y])
		if not texts.has(upgrade.display_name):
			failures.append("카드에 이름 없음: %s (%s)" % [upgrade.id, str(texts)])
		if not texts.has(upgrade.description):
			failures.append("카드에 효과 설명·수치 없음: %s (%s)" % [upgrade.id, str(texts)])
		var badge := "희귀" if upgrade.rarity == UpgradeDef.Rarity.RARE else "일반"
		if not texts.has(badge):
			failures.append("카드에 rarity 뱃지 없음: %s (%s)" % [upgrade.id, badge])
		if not _has_digit(upgrade.description):
			failures.append("강화 설명에 적용 수치가 없음: %s" % upgrade.id)

	if cards.size() > 1:
		cards[1].pressed.emit()
		if pressed.size() != 1 or pressed[0] != 1:
			failures.append("카드 탭이 선택 인덱스를 올리지 않음 (%s)" % str(pressed))

	_teardown(host, overlay)
	return failures

static func _find_column(overlay: Control) -> VBoxContainer:
	for child in overlay.get_children():
		var column := child as VBoxContainer
		if column != null:
			return column
	return null

static func _label_texts(node: Node) -> PackedStringArray:
	var texts := PackedStringArray()
	var label := node as Label
	if label != null:
		texts.append(label.text)
	for child in node.get_children():
		texts.append_array(_label_texts(child))
	return texts

static func _has_digit(text: String) -> bool:
	for i in range(text.length()):
		if text[i].is_valid_int():
			return true
	return false

static func _teardown(host: Node, overlay: Control) -> void:
	host.remove_child(overlay)
	overlay.queue_free()
