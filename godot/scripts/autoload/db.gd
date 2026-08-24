extends Node
## 정적 게임 데이터(.tres) 인덱스. id 조회와 무결성 검증을 소유한다.

const _CELL_RES := [
	preload("res://data/cells/macrophage.tres"),
	preload("res://data/cells/neutrophil.tres"),
	preload("res://data/cells/b_cell.tres"),
]
const _ENEMY_RES := [
	preload("res://data/enemies/bacteria_swarm.tres"),
	preload("res://data/enemies/armored_bacteria.tres"),
	preload("res://data/enemies/fast_bacteria.tres"),
]
const _CHAPTER_RES := [
	preload("res://data/chapters/chapter_1.tres"),
]
const _UPGRADE_RES := [
	preload("res://data/upgrades/u_atk_innate.tres"),
	preload("res://data/upgrades/u_atk_adaptive.tres"),
	preload("res://data/upgrades/u_atk_all.tres"),
	preload("res://data/upgrades/u_atkspd_all.tres"),
	preload("res://data/upgrades/u_mark_bonus.tres"),
	preload("res://data/upgrades/u_skill_cd.tres"),
	preload("res://data/upgrades/u_base_regen.tres"),
	preload("res://data/upgrades/u_reinforce_charge.tres"),
	preload("res://data/upgrades/u_wave_shield.tres"),
	preload("res://data/upgrades/u_slow_aura.tres"),
	preload("res://data/upgrades/u_crit.tres"),
]

var cells: Dictionary = {}
var enemies: Dictionary = {}
var stages: Dictionary = {}
var upgrades: Dictionary = {}
var cell_order: Array[StringName] = []
var chapter_list: Array[ChapterDef] = []
var upgrade_list: Array[UpgradeDef] = []
var upgrade_order: Array[StringName] = []

func _ready() -> void:
	var errors := validate_and_index()
	for message in errors:
		push_error("Db: " + message)

## 인덱스를 재구축하고 무결성 오류 목록을 반환한다. 스모크 테스트가 직접 호출한다.
func validate_and_index() -> PackedStringArray:
	var errors := PackedStringArray()
	cells.clear()
	enemies.clear()
	stages.clear()
	upgrades.clear()
	cell_order.clear()
	chapter_list.clear()
	upgrade_list.clear()
	upgrade_order.clear()

	for res: Resource in _CELL_RES:
		var cell_def := res as CellDef
		if cell_def == null:
			errors.append("CellDef 캐스트 실패: %s" % res.resource_path)
			continue
		if cell_def.id == &"":
			errors.append("빈 cell id: %s" % cell_def.resource_path)
		if cells.has(cell_def.id):
			errors.append("중복 cell id: %s" % cell_def.id)
		if cell_def.skill == null:
			errors.append("skill 누락: %s" % cell_def.id)
		cells[cell_def.id] = cell_def
		cell_order.append(cell_def.id)

	for res: Resource in _ENEMY_RES:
		var enemy_def := res as EnemyDef
		if enemy_def == null:
			errors.append("EnemyDef 캐스트 실패: %s" % res.resource_path)
			continue
		if enemies.has(enemy_def.id):
			errors.append("중복 enemy id: %s" % enemy_def.id)
		enemies[enemy_def.id] = enemy_def

	for res: Resource in _UPGRADE_RES:
		var upgrade_def := res as UpgradeDef
		if upgrade_def == null:
			errors.append("UpgradeDef 캐스트 실패: %s" % res.resource_path)
			continue
		if upgrades.has(upgrade_def.id):
			errors.append("중복 upgrade id: %s" % upgrade_def.id)
		upgrades[upgrade_def.id] = upgrade_def
		upgrade_list.append(upgrade_def)
		upgrade_order.append(upgrade_def.id)

	var seen_orders: Dictionary = {}
	for res: Resource in _CHAPTER_RES:
		var chapter_def := res as ChapterDef
		if chapter_def == null:
			errors.append("ChapterDef 캐스트 실패: %s" % res.resource_path)
			continue
		chapter_list.append(chapter_def)
		for stage_def in chapter_def.stages:
			if stage_def == null:
				errors.append("null stage: %s" % chapter_def.id)
				continue
			if stages.has(stage_def.id):
				errors.append("중복 stage id: %s" % stage_def.id)
			if stage_def.waves.is_empty():
				errors.append("웨이브 없는 stage: %s" % stage_def.id)
			if seen_orders.has(stage_def.order):
				errors.append("중복 stage order: %s" % stage_def.id)
			seen_orders[stage_def.order] = true
			for wave in stage_def.waves:
				if wave == null:
					errors.append("null wave: %s" % stage_def.id)
					continue
				for entry in wave.spawns:
					if entry == null or entry.enemy == null:
						errors.append("적 참조 누락: %s / %s" % [stage_def.id, wave.display_name])
					elif not enemies.has(entry.enemy.id):
						errors.append("미등록 적 참조: %s / %s" % [stage_def.id, entry.enemy.id])
			stages[stage_def.id] = stage_def

	return errors

func cell(id: StringName) -> CellDef:
	return cells.get(id)

func enemy(id: StringName) -> EnemyDef:
	return enemies.get(id)

func stage(id: StringName) -> StageDef:
	return stages.get(id)

func upgrade(id: StringName) -> UpgradeDef:
	return upgrades.get(id)

## 챕터 정의 순서대로의 전체 스테이지 목록.
func stage_sequence() -> Array[StageDef]:
	var sequence: Array[StageDef] = []
	for chapter_def in chapter_list:
		for stage_def in chapter_def.stages:
			sequence.append(stage_def)
	return sequence

func teammate_ids(leader_id: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in cell_order:
		if id != leader_id:
			ids.append(id)
	return ids
