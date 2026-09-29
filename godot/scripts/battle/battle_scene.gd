extends ScreenBase
## 전투 화면 글루: 배경·월드·HUD·오버레이(강화 3택·일시정지)를 조립하고 BattleController를 프레임마다 구동한다.

const FxNodeScript := preload("res://scripts/battle/fx_node.gd")

var _stage_id: StringName
var _restore := false
var _controller: BattleController
var _world: Node2D
var _hud: BattleHud
var _upgrade_overlay: UpgradeOverlay
var _pause_overlay: PauseOverlay

func setup(args: Dictionary) -> void:
	_stage_id = args.get("stage", GameState.next_stage().id)
	_restore = bool(args.get("restore", false))

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var background := ArenaBackground.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	background.setup(_stage_id)

	_world = Node2D.new()
	add_child(_world)

	_hud = BattleHud.new()
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_hud)

	var config := GameState.build_battle_config(_stage_id, get_viewport_rect().size, _restore)
	_controller = BattleController.new(config, _world)
	_controller.status_changed.connect(_hud.set_status)
	_controller.base_changed.connect(_hud.update_base)
	_controller.fx_requested.connect(_spawn_fx)
	_controller.upgrade_offered.connect(_show_upgrade_overlay)
	_controller.run_snapshot.connect(GameState.save_run)
	_controller.battle_finished.connect(_on_battle_finished)
	_hud.skill_pressed.connect(func() -> void: _controller.use_leader_skill())
	_hud.reinforce_pressed.connect(func() -> void: _controller.call_reinforcement())
	_hud.pause_pressed.connect(func() -> void: open_pause())
	_controller.start()

## Android back: 전투 중이면 일시정지 오버레이를 열고, 열려 있으면 닫는다.
## 강화 3택 중에는 선택이 필수라 무시한다 (03-ui-ux-spec.md:34~35).
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		handle_back_request()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		handle_focus_out()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and handle_back_request():
		get_viewport().set_input_as_handled()

## true 를 반환하면 back 을 소비했다는 뜻이다.
func handle_back_request() -> bool:
	if _controller == null:
		return false
	if is_instance_valid(_pause_overlay):
		close_pause()
		return true
	return open_pause()

## 앱이 백그라운드로 가면 전투 중일 때 일시정지 상태로 들어간다 (03-ui-ux-spec.md:36).
func handle_focus_out() -> bool:
	return open_pause()

func open_pause() -> bool:
	if _controller == null or is_instance_valid(_pause_overlay):
		return false
	if not _controller.pause():
		return false
	_pause_overlay = PauseOverlay.new()
	_pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_pause_overlay)
	_pause_overlay.setup()
	_pause_overlay.resume_pressed.connect(close_pause)
	_pause_overlay.give_up_pressed.connect(_on_give_up)
	return true

func close_pause() -> void:
	if is_instance_valid(_pause_overlay):
		_pause_overlay.queue_free()
		_pause_overlay = null
	if _controller != null:
		_controller.resume()

func _on_give_up() -> void:
	if is_instance_valid(_pause_overlay):
		_pause_overlay.queue_free()
		_pause_overlay = null
	if _controller != null:
		_controller.retreat()

func _process(delta: float) -> void:
	if _controller == null or _controller.state == BattleController.State.FINISHED:
		return
	_controller.step(delta)
	_hud.update_hud(_controller.wave_index, _controller.stage().waves.size(), _controller.elapsed)
	_hud.update_skill(_controller.skill().id, _controller.skill().display_name, _controller.skill_cooldown, _controller.skill_max_cooldown())
	_hud.update_reinforce(_controller.reinforce_gauge, BattleController.REINFORCE_MAX, _controller.can_reinforce())

func _spawn_fx(kind: String, world_pos: Vector2, radius: float, color: Color, lifetime: float) -> void:
	var fx: Node2D = FxNodeScript.new()
	fx.position = world_pos
	fx.setup(kind, radius, color, lifetime)
	_world.add_child(fx)

func _show_upgrade_overlay(choices: Array[UpgradeDef]) -> void:
	if is_instance_valid(_upgrade_overlay):
		return
	_upgrade_overlay = UpgradeOverlay.new()
	# 부모가 add_child 전에 앵커를 지정한다 — 이후 앵커 기준으로 size가 확정된다 (Godot 4.7).
	_upgrade_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_upgrade_overlay)
	_upgrade_overlay.setup(choices)
	_upgrade_overlay.choice_selected.connect(_on_upgrade_selected)

func _on_upgrade_selected(index: int) -> void:
	if not _controller.choose_upgrade(index):
		return
	if is_instance_valid(_upgrade_overlay):
		_upgrade_overlay.queue_free()
		_upgrade_overlay = null

func _on_battle_finished(summary: Dictionary) -> void:
	GameState.on_battle_finished(summary)
	go(&"result", {"summary": summary})
