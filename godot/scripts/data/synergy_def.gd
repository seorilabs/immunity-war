class_name SynergyDef
extends Resource

@export var id: StringName
@export var display_name: String
@export var description: String
@export var required_tag: StringName
@export var required_count: int = 2
@export var effect_kind: UpgradeDef.EffectKind = UpgradeDef.EffectKind.STAT_MULT_DAMAGE
@export var value: float = 0.0
