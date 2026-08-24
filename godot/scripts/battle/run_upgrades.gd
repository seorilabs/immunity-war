class_name RunUpgrades
extends RefCounted
## 런 동안 누적되는 강화 효과. 전투 상태에만 반영되며 UI를 참조하지 않는다.
## 피해 계열은 CombatRules 의 upgrade_mult / mark_bonus 인자로 흘러간다.

## RunUpgrades 가 실제로 반영할 수 있는 effect_kind. 풀에는 이 목록의 강화만 들어간다.
const SUPPORTED_KINDS := [
	UpgradeDef.EffectKind.STAT_MULT_DAMAGE,
	UpgradeDef.EffectKind.STAT_MULT_ATTACK_RATE,
	UpgradeDef.EffectKind.MARK_BONUS,
	UpgradeDef.EffectKind.SKILL_CD_MULT,
	UpgradeDef.EffectKind.BASE_REGEN,
	UpgradeDef.EffectKind.ON_KILL_HEAL,
	UpgradeDef.EffectKind.SLOW_AURA,
]

var taken: Array[StringName] = []
var damage_mult := 1.0
var tag_damage_mult: Dictionary = {}
var attack_rate_mult := 1.0
var mark_bonus := 0.0
var skill_cooldown_mult := 1.0
var base_regen_per_wave := 0.0
var on_kill_heal := 0.0
var enemy_speed_mult := 1.0

func apply(upgrade: UpgradeDef) -> void:
	if upgrade == null:
		return
	taken.append(upgrade.id)
	match upgrade.effect_kind:
		UpgradeDef.EffectKind.STAT_MULT_DAMAGE:
			if upgrade.target_tag == &"":
				damage_mult *= 1.0 + upgrade.value
			else:
				var current := float(tag_damage_mult.get(upgrade.target_tag, 1.0))
				tag_damage_mult[upgrade.target_tag] = current * (1.0 + upgrade.value)
		UpgradeDef.EffectKind.STAT_MULT_ATTACK_RATE:
			attack_rate_mult *= maxf(0.2, 1.0 - upgrade.value)
		UpgradeDef.EffectKind.MARK_BONUS:
			mark_bonus += upgrade.value
		UpgradeDef.EffectKind.SKILL_CD_MULT:
			skill_cooldown_mult *= maxf(0.2, 1.0 - upgrade.value)
		UpgradeDef.EffectKind.BASE_REGEN:
			base_regen_per_wave += upgrade.value
		UpgradeDef.EffectKind.ON_KILL_HEAL:
			on_kill_heal += upgrade.value
		UpgradeDef.EffectKind.SLOW_AURA:
			enemy_speed_mult *= maxf(0.3, 1.0 - upgrade.value)
		_:
			push_warning("RunUpgrades: 미구현 effect_kind (%s / %d)" % [upgrade.id, upgrade.effect_kind])

## 공격 세포의 태그에 걸린 강화까지 곱해 CombatRules 의 upgrade_mult 로 넘길 값을 만든다.
func damage_mult_for(attacker_tags: Array[StringName]) -> float:
	var mult := damage_mult
	for tag in attacker_tags:
		if tag_damage_mult.has(tag):
			mult *= float(tag_damage_mult[tag])
	return mult

func has(upgrade_id: StringName) -> bool:
	return taken.has(upgrade_id)
