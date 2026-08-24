extends ScreenBase
## 전투 화면 글루: 배경·월드·HUD·강화 오버레이를 조립하고 BattleController를 프레임마다 구동한다.

const FxNodeScript := preload("res://scripts/battle/fx_node.gd")

var _stage_id: StringName
var _restore := false
var _controller: BattleController
var _world: Node2D
var _hud: BattleHud

func setup(args: Dictionary) -> void:
	_stage_id = args.get("stage", GameState.next_stage().id)
	_restore = bool(args.get("restore", false))

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var background := ArenaBackground.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	_world = Node2D.new()
	add_child(_world)

	_hud = BattleHud.new()
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_hud)

	var config := GameState.build_battle_config(_stage_id, get_viewport_rect().size, _restore)
	_controller = BattleController.new(config, _world)
	_controller.status_changed.connect(_hud.set_status)
	_controller.base_changed.connect(_hud.update_base)
	_controller.reinforce_changed.connect(_hud.update_reinforce)
	_controller.fx_requested.connect(_spawn_fx)
	_controller.upgrade_offered.connect(_show_upgrade_overlay)
	_controller.run_snapshot.connect(GameState.save_run)
	_controller.battle_finished.connect(_on_battle_finished)
	_hud.skill_pressed.connect(func() -> void: _controller.use_leader_skill())
	_hud.reinforce_pressed.connect(func() -> void: _controller.use_reinforcement())
	_hud.retreat_pressed.connect(func() -> void: _controller.retreat())
	_controller.start()

func _process(delta: float) -> void:
	if _controller == null or _controller.state == BattleController.State.FINISHED:
		return
	_controller.step(delta)
	_hud.update_hud(_controller.wave_index, _controller.stage().waves.size(), _controller.elapsed)
	_hud.update_skill(_controller.skill().display_name, _controller.skill_cooldown, _controller.skill_max_cooldown())

func _spawn_fx(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float) -> void:
	var fx: Node2D = FxNodeScript.new()
	fx.position = world_pos
	fx.setup(kind, radius, color, lifetime)
	_world.add_child(fx)

func _show_upgrade_overlay(options: Array[UpgradeDef]) -> void:
	var overlay := UpgradeOverlay.new()
	overlay.configure(options)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.position = Vector2.ZERO
	overlay.size = get_viewport_rect().size
	overlay.picked.connect(func(index: int) -> void:
		overlay.queue_free()
		_controller.apply_upgrade(index))
	add_child(overlay)

func _on_battle_finished(summary: Dictionary) -> void:
	GameState.on_battle_finished(summary)
	go(&"result", {"summary": summary})
