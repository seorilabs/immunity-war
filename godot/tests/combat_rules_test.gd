extends RefCounted
## CombatRules 피해 계산 test vector. 규격 출처: docs/game-design/02-gdd.md (피해 계산 / 상성표 / CON-002).

const EPSILON := 0.0001

## GDD 상성표 사본. CombatRules.TYPE_MULT 가 문서와 어긋나면 실패한다.
const EXPECTED_TYPE_MULT := {
	&"phagocytosis": {&"swarm": 1.4, &"armored": 0.8, &"fast": 1.0, &"toxin": 1.0, &"biofilm": 0.8},
	&"inflammatory": {&"swarm": 1.3, &"armored": 1.0, &"fast": 1.0, &"toxin": 1.2, &"biofilm": 0.8},
	&"antibody": {&"swarm": 1.0, &"armored": 1.2, &"fast": 1.3, &"toxin": 1.0, &"biofilm": 1.0},
	&"lytic": {&"swarm": 0.7, &"armored": 1.5, &"fast": 1.0, &"toxin": 1.0, &"biofilm": 1.3},
}

## GDD 로스터/적 정의의 태그. 데이터(.tres)와 문서가 어긋나면 실패한다.
const EXPECTED_CELL_TAGS := {
	&"macrophage": [&"innate", &"frontline", &"phagocytosis"],
	&"neutrophil": [&"innate", &"frontline", &"inflammatory"],
	&"b_cell": [&"adaptive", &"ranged", &"antibody"],
}
const EXPECTED_ENEMY_TAGS := {
	&"bacteria_swarm": [&"swarm"],
	&"armored_bacteria": [&"armored"],
	&"fast_bacteria": [&"fast"],
}

static func run() -> PackedStringArray:
	var failures := PackedStringArray()
	_check_vectors(failures)
	_check_table(failures)
	_check_data_tags(failures)
	return failures

static func _check_vectors(failures: PackedStringArray) -> void:
	var untagged: Array[StringName] = []
	var phagocytosis: Array[StringName] = [&"innate", &"frontline", &"phagocytosis"]
	var lytic: Array[StringName] = [&"innate", &"ranged", &"lytic"]
	var support: Array[StringName] = [&"innate", &"support", &"sentinel"]
	var swarm: Array[StringName] = [&"swarm"]

	_expect(failures, "CON-002 표식 중 100 피해",
		CombatRules.final_damage(100.0, untagged, swarm, true), 145.0)
	_expect(failures, "phagocytosis→swarm 100 피해",
		CombatRules.final_damage(100.0, phagocytosis, swarm, false), 140.0)
	_expect(failures, "lytic→swarm 100 피해",
		CombatRules.final_damage(100.0, lytic, swarm, false), 70.0)
	_expect(failures, "표식+상성 중첩(phagocytosis→swarm 표식)",
		CombatRules.final_damage(100.0, phagocytosis, swarm, true), 203.0)
	_expect(failures, "support 계열은 상성 중립",
		CombatRules.final_damage(100.0, support, swarm, false), 100.0)
	_expect(failures, "upgrade·level 배율 곱연산",
		CombatRules.final_damage(100.0, phagocytosis, swarm, false, 1.2, 1.5), 252.0)

static func _check_table(failures: PackedStringArray) -> void:
	for attacker_tag: StringName in EXPECTED_TYPE_MULT:
		if not CombatRules.TYPE_MULT.has(attacker_tag):
			failures.append("TYPE_MULT 행 누락: %s" % attacker_tag)
			continue
		var expected_row: Dictionary = EXPECTED_TYPE_MULT[attacker_tag]
		var row: Dictionary = CombatRules.TYPE_MULT[attacker_tag]
		for defender_tag: StringName in expected_row:
			var defender_tags: Array[StringName] = [defender_tag]
			var attacker_tags: Array[StringName] = [attacker_tag]
			_expect(failures, "TYPE_MULT %s→%s" % [attacker_tag, defender_tag],
				CombatRules.type_mult(attacker_tags, defender_tags), float(expected_row[defender_tag]))
			if not row.has(defender_tag):
				failures.append("TYPE_MULT 열 누락: %s→%s" % [attacker_tag, defender_tag])

static func _check_data_tags(failures: PackedStringArray) -> void:
	for id: StringName in EXPECTED_CELL_TAGS:
		var cell := Db.cell(id)
		if cell == null:
			failures.append("세포 정의 누락: %s" % id)
			continue
		_expect_tags(failures, "세포 %s 태그" % id, cell.tags, EXPECTED_CELL_TAGS[id])
	for id: StringName in EXPECTED_ENEMY_TAGS:
		var enemy := Db.enemy(id)
		if enemy == null:
			failures.append("적 정의 누락: %s" % id)
			continue
		_expect_tags(failures, "적 %s 태그" % id, enemy.tags, EXPECTED_ENEMY_TAGS[id])

static func _expect(failures: PackedStringArray, label: String, actual: float, expected: float) -> void:
	if absf(actual - expected) > EPSILON:
		failures.append("%s: 기대 %s, 실제 %s" % [label, expected, actual])

static func _expect_tags(failures: PackedStringArray, label: String, actual: Array[StringName], expected: Array) -> void:
	for tag: StringName in expected:
		if not actual.has(tag):
			failures.append("%s: %s 누락 (실제 %s)" % [label, tag, str(actual)])
