class_name CombatRules
## 피해·위협도 계산의 단일 경로. final = base x 표식 x 상성 x 강화 x 레벨 (02-gdd 피해 계산).

const MARK_MULT := 1.45
const LEVEL_STEP := 0.12
const CRIT_MULT := 2.0

## 공격 태그 x 방어 태그 상성표 (02-gdd 상성표와 1:1).
const TYPE_MULT := {
	&"phagocytosis": {&"swarm": 1.4, &"armored": 0.8, &"biofilm": 0.8},
	&"inflammatory": {&"swarm": 1.3, &"toxin": 1.2, &"biofilm": 0.8},
	&"antibody": {&"armored": 1.2, &"fast": 1.3},
	&"lytic": {&"armored": 1.5, &"biofilm": 1.3, &"swarm": 0.7},
}

static func level_mult(level: int) -> float:
	return 1.0 + LEVEL_STEP * float(level - 1)

static func type_mult(attack_tags: Array[StringName], defense_tags: Array[StringName]) -> float:
	var mult := 1.0
	for attack_tag in attack_tags:
		if TYPE_MULT.has(attack_tag):
			var row: Dictionary = TYPE_MULT[attack_tag]
			for defense_tag in defense_tags:
				mult *= float(row.get(defense_tag, 1.0))
	return mult

static func threat_score(hp: float, position_x: float, base_damage: float) -> float:
	return hp + maxf(0.0, 280.0 - position_x) * 0.35 + base_damage * 2.0
