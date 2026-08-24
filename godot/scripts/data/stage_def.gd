class_name StageDef
extends Resource

@export var id: StringName
@export var display_name: String
## 전역 스테이지 순번 (1부터). 보상 공식 Economy.reward_base의 입력.
@export var order: int = 1
@export var base_hp: float = 120.0
## 이 스테이지 적 HP 배율 (난이도 입력).
@export var hp_mult: float = 1.0
@export var is_boss: bool = false
@export var waves: Array[WaveDef] = []
