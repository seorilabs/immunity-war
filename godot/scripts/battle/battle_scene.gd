extends ScreenBase
## 전투 화면 글루: 배경·월드·HUD를 조립하고 BattleController를 프레임마다 구동한다.

const FxNodeScript := preload("res://scripts/battle/fx_node.gd")

var _leader_id: StringName
var _stage_id: StringName
var _controller: BattleController
var _world: Node2D
var _hud: BattleHud

func setup(args: Dictionary) -> void:
	_leader_id = args.get("leader", GameState.selected_leader)
	_stage_id = args.get("stage", GameState.current_stage_id)

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

	var stage := Db.stage(_stage_id)
	var roster: Array[CellDef] = [Db.cell(_leader_id)]
	for teammate_id in Db.teammate_ids(_leader_id):
		roster.append(Db.cell(teammate_id))

	_controller = BattleController.new(stage, roster, _world, get_viewport_rect().size, randi())
	_controller.status_changed.connect(_hud.set_status)
	_controller.fx_requested.connect(_spawn_fx)
	_controller.battle_finished.connect(_on_battle_finished)
	_hud.skill_pressed.connect(func() -> void: _controller.use_leader_skill())
	_hud.retreat_pressed.connect(func() -> void: _controller.retreat())
	_controller.start()

func _process(delta: float) -> void:
	if _controller == null or _controller.state == BattleController.State.FINISHED:
		return
	_controller.step(delta)
	_hud.update_hud(_controller.base_hp, _controller.wave_index, _controller.stage.waves.size(), _controller.elapsed)
	_hud.update_skill(_controller.skill().display_name, _controller.skill_cooldown, _controller.skill().cooldown)

func _spawn_fx(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float) -> void:
	var fx: Node2D = FxNodeScript.new()
	fx.position = world_pos
	fx.setup(kind, radius, color, lifetime)
	_world.add_child(fx)

func _on_battle_finished(summary: Dictionary) -> void:
	GameState.last_summary = summary
	go(&"result", {"summary": summary})
