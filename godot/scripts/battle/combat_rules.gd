class_name CombatRules
## 피해·위협도 계산의 단일 경로. 상성·강화·레벨 배율은 Phase 2에서 이 경로에 합류한다.

const MARK_MULT := 1.45

static func final_damage(base_damage: float, marked: bool) -> float:
	var damage := base_damage
	if marked:
		damage *= MARK_MULT
	return damage

static func threat_score(hp: float, position_x: float, base_damage: float) -> float:
	return hp + maxf(0.0, 280.0 - position_x) * 0.35 + base_damage * 2.0
