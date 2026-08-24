class_name BattleConfig
extends RefCounted
## 전투 진입 계약. GameState가 조립해 BattleController에 주입한다.

var stage: StageDef
var roster: Array[CellDef] = []
## 해금됐지만 덱에 없는 세포 (증원 소환 후보).
var reserve_cells: Array[CellDef] = []
var levels: Dictionary = {}
var rng_seed := 0
var arena_size := Vector2(390.0, 844.0)

## run 스냅숏 복원용 (없으면 새 전투).
var start_wave_index := 0
var start_base_hp := -1.0
var upgrade_ids: Array[StringName] = []
var reinforce_gauge := 0.0

func cell_level(cell_id: StringName) -> int:
	return int(levels.get(cell_id, 1))
