class_name UnitRegistry
extends RefCounted
## 전투 중 유닛 목록과 타깃 질의를 소유한다.

var cells: Array[CellUnit] = []
var enemies: Array[EnemyUnit] = []
var projectiles: Array[Projectile] = []

func find_nearest_enemy(from_position: Vector2, max_distance: float = 9999.0) -> EnemyUnit:
	var best: EnemyUnit = null
	var best_distance := max_distance
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.alive:
			var dist := from_position.distance_to(enemy.position)
			if dist < best_distance:
				best = enemy
				best_distance = dist
	return best

func highest_threat_enemy() -> EnemyUnit:
	var best: EnemyUnit = null
	var best_score := -1.0
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.alive:
			var score := enemy.threat_score()
			if score > best_score:
				best_score = score
				best = enemy
	return best

func alive_enemies() -> Array[EnemyUnit]:
	var result: Array[EnemyUnit] = []
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy.alive:
			result.append(enemy)
	return result

func alive_cells() -> Array[CellUnit]:
	var result: Array[CellUnit] = []
	for cell in cells:
		if is_instance_valid(cell) and not cell.is_queued_for_deletion():
			result.append(cell)
	return result

func prune() -> void:
	cells = alive_cells()
	enemies = alive_enemies()
	var alive_projectiles: Array[Projectile] = []
	for projectile in projectiles:
		if is_instance_valid(projectile) and not projectile.is_queued_for_deletion():
			alive_projectiles.append(projectile)
	projectiles = alive_projectiles
	var active_cells: Array[CellUnit] = []
	for cell in cells:
		if is_instance_valid(cell) and cell.active:
			active_cells.append(cell)
	cells = active_cells
