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
const _UPGRADE_RES := [
	preload("res://data/upgrades/cytokine_burst.tres"),
	preload("res://data/upgrades/rapid_response.tres"),
	preload("res://data/upgrades/opsonin_boost.tres"),
	preload("res://data/upgrades/signal_relay.tres"),
	preload("res://data/upgrades/tissue_repair.tres"),
	preload("res://data/upgrades/phagocytic_feast.tres"),
	preload("res://data/upgrades/mucus_trap.tres"),
	preload("res://data/upgrades/frontline_drill.tres"),
]
const _STAGE_RES := [
	preload("res://data/stages/stage_1_1.tres"),
]

var cells: Dictionary = {}
var enemies: Dictionary = {}
var stages: Dictionary = {}
var upgrades: Dictionary = {}
var cell_order: Array[StringName] = []
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
	upgrade_order.clear()

	for res: Resource in _CELL_RES:
		var cell := res as CellDef
		if cell == null:
			errors.append("CellDef 캐스트 실패: %s" % res.resource_path)
			continue
		if cell.id == &"":
			errors.append("빈 cell id: %s" % cell.resource_path)
		if cells.has(cell.id):
			errors.append("중복 cell id: %s" % cell.id)
		if cell.skill == null:
			errors.append("skill 누락: %s" % cell.id)
		cells[cell.id] = cell
		cell_order.append(cell.id)

	for res: Resource in _ENEMY_RES:
		var enemy := res as EnemyDef
		if enemy == null:
			errors.append("EnemyDef 캐스트 실패: %s" % res.resource_path)
			continue
		if enemy.id == &"":
			errors.append("빈 enemy id: %s" % enemy.resource_path)
		if enemies.has(enemy.id):
			errors.append("중복 enemy id: %s" % enemy.id)
		enemies[enemy.id] = enemy

	for res: Resource in _UPGRADE_RES:
		var upgrade := res as UpgradeDef
		if upgrade == null:
			errors.append("UpgradeDef 캐스트 실패: %s" % res.resource_path)
			continue
		if upgrade.id == &"":
			errors.append("빈 upgrade id: %s" % upgrade.resource_path)
		if upgrades.has(upgrade.id):
			errors.append("중복 upgrade id: %s" % upgrade.id)
		if not RunUpgrades.SUPPORTED_KINDS.has(upgrade.effect_kind):
			errors.append("미구현 effect_kind 강화: %s (%d)" % [upgrade.id, upgrade.effect_kind])
		upgrades[upgrade.id] = upgrade
		upgrade_order.append(upgrade.id)

	for res: Resource in _STAGE_RES:
		var stage := res as StageDef
		if stage == null:
			errors.append("StageDef 캐스트 실패: %s" % res.resource_path)
			continue
		if stages.has(stage.id):
			errors.append("중복 stage id: %s" % stage.id)
		if stage.waves.is_empty():
			errors.append("웨이브 없는 stage: %s" % stage.id)
		for wave in stage.waves:
			if wave == null:
				errors.append("null wave: %s" % stage.id)
				continue
			for entry in wave.spawns:
				if entry == null or entry.enemy == null:
					errors.append("적 참조 누락: %s / %s" % [stage.id, wave.display_name])
				elif not enemies.has(entry.enemy.id):
					errors.append("미등록 적 참조: %s / %s" % [stage.id, entry.enemy.id])
		stages[stage.id] = stage

	return errors

func cell(id: StringName) -> CellDef:
	return cells.get(id)

func enemy(id: StringName) -> EnemyDef:
	return enemies.get(id)

func upgrade(id: StringName) -> UpgradeDef:
	return upgrades.get(id)

func stage(id: StringName) -> StageDef:
	return stages.get(id)

func teammate_ids(leader_id: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in cell_order:
		if id != leader_id:
			ids.append(id)
	return ids
