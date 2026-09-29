class_name SpriteLoader
extends RefCounted
## Optional-sprite helper. Loads PNG from res:// at spawn time and falls
## back silently when missing so callers always work. Used by BattleController
## to attach AI-generated sprites to CellUnit/EnemyUnit when available.

## MiniMax pipeline produces sprites under:
##   res://assets/sprites/cells/<id>.png
##   res://assets/sprites/enemies/<id>.png
##   res://assets/sprites/icons/<id>.png
##   res://assets/sprites/backgrounds/<id>.png
## and id matches the cell_def.id / enemy_def.id / skill_def.id / upgrade_def.id.

const CELLS_DIR := "res://assets/sprites/cells"
const ENEMIES_DIR := "res://assets/sprites/enemies"
const ICONS_DIR := "res://assets/sprites/icons"
const BACKGROUNDS_DIR := "res://assets/sprites/backgrounds"

static func try_load(path: String) -> Texture2D:
	if path.is_empty():
		return null
	if not ResourceLoader.exists(path):
		return null
	var resource := ResourceLoader.load(path)
	if resource is Texture2D:
		return resource
	return null

static func cell_path(id: StringName) -> String:
	return "%s/%s.png" % [CELLS_DIR, String(id)]

static func enemy_path(id: StringName) -> String:
	return "%s/%s.png" % [ENEMIES_DIR, String(id)]

## Skill icons live next to upgrade icons and share the icons/ directory.
## skill id == role id with `_skill` suffix; we keep the suffix in the filename.
static func skill_icon_path(skill_id: StringName) -> String:
	return "%s/%s.png" % [ICONS_DIR, String(skill_id)]

static func upgrade_icon_path(upgrade_id: StringName) -> String:
	return "%s/%s.png" % [ICONS_DIR, String(upgrade_id)]

## Stage ids in data are like "1-1", "1-2", "1-3" (ch1). Pull the chapter
## digit out of the head and look for backgrounds/chN_skin.png.
static func background_path(stage_id: StringName) -> String:
	var s := String(stage_id)
	var first_digit := ""
	for i in range(s.length()):
		var c := s.unicode_at(i)
		if c >= 0x31 and c <= 0x39:  # '1'..'9'
			first_digit = String.chr(c)
			break
	if first_digit.is_empty():
		return ""
	return "%s/ch%s_skin.png" % [BACKGROUNDS_DIR, first_digit]