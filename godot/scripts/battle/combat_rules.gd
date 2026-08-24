class_name CombatRules
## 피해·위협도 계산의 단일 경로. GDD `docs/game-design/02-gdd.md` 피해 계산 규격을 소유한다.
##
## final_damage = base_damage x mark_mult x type_mult x upgrade_mult x level_mult
## (크리티컬은 rng가 필요해 컨트롤러가 별도로 CRIT_MULT를 곱한다)

## CON-002 표식 기본 배율. 런 강화(UpgradeDef MARK_BONUS)는 이 값에 가산된다.
const MARK_MULT := 1.45
## CON-006 레벨 스탯 곡선 기울기.
const LEVEL_STEP := 0.12
const CRIT_MULT := 2.0

## 공격 태그 x 방어 태그 상성표 (02-gdd.md 상성표).
## 표에 없는 공격 태그(support 계열)는 전 행 1.0으로 취급한다.
const TYPE_MULT := {
	&"phagocytosis": {&"swarm": 1.4, &"armored": 0.8, &"fast": 1.0, &"toxin": 1.0, &"biofilm": 0.8},
	&"inflammatory": {&"swarm": 1.3, &"armored": 1.0, &"fast": 1.0, &"toxin": 1.2, &"biofilm": 0.8},
	&"antibody": {&"swarm": 1.0, &"armored": 1.2, &"fast": 1.3, &"toxin": 1.0, &"biofilm": 1.0},
	&"lytic": {&"swarm": 0.7, &"armored": 1.5, &"fast": 1.0, &"toxin": 1.0, &"biofilm": 1.3},
}

static func level_mult(level: int) -> float:
	return 1.0 + LEVEL_STEP * float(level - 1)

## 태그 배열은 canonical 순서(로스터 정의 순)를 따르며, 표에 먼저 걸리는 공격 태그 한 행만 적용한다.
static func type_mult(attacker_tags: Array[StringName], defender_tags: Array[StringName]) -> float:
	for attacker_tag in attacker_tags:
		if not TYPE_MULT.has(attacker_tag):
			continue
		var row: Dictionary = TYPE_MULT[attacker_tag]
		for defender_tag in defender_tags:
			if row.has(defender_tag):
				return float(row[defender_tag])
		return 1.0
	return 1.0

static func final_damage(
	base_damage: float,
	attacker_tags: Array[StringName],
	defender_tags: Array[StringName],
	marked: bool,
	upgrade_mult: float = 1.0,
	level_multiplier: float = 1.0,
	mark_bonus: float = 0.0
) -> float:
	var damage := base_damage
	if marked:
		damage *= MARK_MULT + mark_bonus
	damage *= type_mult(attacker_tags, defender_tags)
	damage *= upgrade_mult
	damage *= level_multiplier
	return damage

static func threat_score(hp: float, position_x: float, base_damage: float) -> float:
	return hp + maxf(0.0, 280.0 - position_x) * 0.35 + base_damage * 2.0
