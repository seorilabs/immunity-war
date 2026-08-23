class_name UpgradeDef
extends Resource

enum Rarity {COMMON, RARE}
enum EffectKind {
	STAT_MULT_DAMAGE,
	STAT_MULT_ATTACK_RATE,
	MARK_BONUS,
	SKILL_CD_MULT,
	BASE_REGEN,
	REINFORCE_CHARGE,
	ON_KILL_HEAL,
	WAVE_SHIELD,
	SLOW_AURA,
	CRIT,
}

@export var id: StringName
@export var display_name: String
@export var description: String
@export var rarity: Rarity = Rarity.COMMON
@export var effect_kind: EffectKind = EffectKind.STAT_MULT_DAMAGE
@export var target_tag: StringName
@export var value: float = 0.0
