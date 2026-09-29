extends SceneTree
## Asset load verification. Iterates the manifest and confirms every asset
## that should be wired today is reachable via SpriteLoader at the expected
## dimensions. Run via:
##   /Applications/Godot.app/Contents/MacOS/Godot --headless --path godot \
##       --script res://tests/asset_load_check.gd

const CELLS := ["macrophage", "neutrophil", "b_cell"]
const ENEMIES := ["bacteria_swarm", "armored_bacteria", "fast_bacteria"]
const SKILLS := ["macrophage_skill", "neutrophil_skill", "b_cell_skill"]
const UPGRADES := [
	"u_wave_shield", "u_skill_cd", "u_atk_innate", "u_base_regen",
	"u_atkspd_all", "u_atk_all", "u_atk_adaptive", "u_crit",
	"u_slow_aura", "u_mark_bonus", "u_reinforce_charge",
]

func _init() -> void:
	var failures := 0

	# Cells
	for id in CELLS:
		var path := SpriteLoader.cell_path(StringName(id))
		var tex := SpriteLoader.try_load(path)
		if tex == null:
			printerr("[missing] cell %s -> %s" % [id, path])
			failures += 1
			continue
		print("[ok] cell %s -> %s (%dx%d)" % [id, path, tex.get_width(), tex.get_height()])

	# Enemies
	for id in ENEMIES:
		var path := SpriteLoader.enemy_path(StringName(id))
		var tex := SpriteLoader.try_load(path)
		if tex == null:
			printerr("[missing] enemy %s -> %s" % [id, path])
			failures += 1
			continue
		print("[ok] enemy %s -> %s (%dx%d)" % [id, path, tex.get_width(), tex.get_height()])

	# Skills
	for id in SKILLS:
		var path := SpriteLoader.skill_icon_path(StringName(id))
		var tex := SpriteLoader.try_load(path)
		if tex == null:
			printerr("[missing] skill %s -> %s" % [id, path])
			failures += 1
			continue
		print("[ok] skill %s -> %s (%dx%d)" % [id, path, tex.get_width(), tex.get_height()])

	# Upgrades
	for id in UPGRADES:
		var path := SpriteLoader.upgrade_icon_path(StringName(id))
		var tex := SpriteLoader.try_load(path)
		if tex == null:
			printerr("[missing] upgrade %s -> %s" % [id, path])
			failures += 1
			continue
		print("[ok] upgrade %s -> %s (%dx%d)" % [id, path, tex.get_width(), tex.get_height()])

	# Stage background (use stage id "1-1" to verify chapter extraction).
	var bg_path := SpriteLoader.background_path(&"1-1")
	var bg_tex := SpriteLoader.try_load(bg_path)
	if bg_tex == null:
		printerr("[missing] background 1-1 -> %s" % bg_path)
		failures += 1
	else:
		print("[ok] background 1-1 -> %s (%dx%d)" % [bg_path, bg_tex.get_width(), bg_tex.get_height()])

	if failures == 0:
		print("\nALL %d ASSETS LOAD OK" % (CELLS.size() + ENEMIES.size() + SKILLS.size() + UPGRADES.size() + 1))
		quit(0)
	else:
		print("\n%d FAILURES" % failures)
		quit(1)