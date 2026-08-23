class_name CellDef
extends Resource

@export var id: StringName
@export var display_name: String
@export var role: String
@export var description: String
@export var color: Color = Color.WHITE
@export var accent: Color = Color.WHITE
@export var hp: float = 100.0
@export var damage: float = 10.0
@export var attack_range: float = 100.0
@export var attack_rate: float = 0.8
@export var speed: float = 90.0
@export var tags: Array[StringName] = []
@export var skill: SkillDef
@export_multiline var result_copy: String
