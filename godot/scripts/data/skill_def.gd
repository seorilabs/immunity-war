class_name SkillDef
extends Resource

enum Kind {PULL_STUN, AOE_BLAST, MARK}

@export var id: StringName
@export var display_name: String
@export var description: String
@export var kind: Kind = Kind.AOE_BLAST
@export var cooldown: float = 6.0
@export var damage: float = 0.0
@export var radius: float = 0.0
@export var forward_offset: float = 0.0
@export var pull_distance: float = 0.0
@export var stun_duration: float = 0.0
@export var mark_duration: float = 0.0
