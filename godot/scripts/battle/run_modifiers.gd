class_name RunModifiers
extends RefCounted
## 런 한정 강화(웨이브 간 3택)의 누적 상태. UpgradeDef를 적용해 배율로 환산한다.

var upgrade_ids: Array[StringName] = []
var _damage_mult: Dictionary = {}
var attack_interval_mult := 1.0
var mark_bonus := 0.0
var skill_cd_mult := 1.0
var base_regen := 0.0
var reinforce_charge_mult := 1.0
var wave_shield := 0.0
var crit_chance := 0.0
var slow_aura_factor := 0.0

func apply(upgrade: UpgradeDef) -> void:
	upgrade_ids.append(upgrade.id)
	match upgrade.effect_kind:
		UpgradeDef.EffectKind.STAT_MULT_DAMAGE:
			var key := upgrade.target_tag
			_damage_mult[key] = float(_damage_mult.get(key, 1.0)) * (1.0 + upgrade.value)
		UpgradeDef.EffectKind.STAT_MULT_ATTACK_RATE:
			attack_interval_mult *= 1.0 - upgrade.value
		UpgradeDef.EffectKind.MARK_BONUS:
			mark_bonus += upgrade.value
		UpgradeDef.EffectKind.SKILL_CD_MULT:
			skill_cd_mult *= 1.0 - upgrade.value
		UpgradeDef.EffectKind.BASE_REGEN:
			base_regen += upgrade.value
		UpgradeDef.EffectKind.REINFORCE_CHARGE:
			reinforce_charge_mult *= 1.0 + upgrade.value
		UpgradeDef.EffectKind.WAVE_SHIELD:
			wave_shield += upgrade.value
		UpgradeDef.EffectKind.CRIT:
			crit_chance = minf(0.6, crit_chance + upgrade.value)
		UpgradeDef.EffectKind.SLOW_AURA:
			slow_aura_factor = minf(0.6, slow_aura_factor + upgrade.value)
		UpgradeDef.EffectKind.ON_KILL_HEAL:
			pass

## 태그 목록에 적용되는 피해 배율. target_tag가 빈 값인 강화는 전체 적용.
func damage_multiplier(tags: Array[StringName]) -> float:
	var mult := float(_damage_mult.get(&"", 1.0))
	for tag in tags:
		mult *= float(_damage_mult.get(tag, 1.0))
	return mult
