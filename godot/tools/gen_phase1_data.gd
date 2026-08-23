# 정적 데이터(.tres) 생성기. 실행:
#   godot --headless --path godot -s tools/gen_phase1_data.gd
# 생성물은 커밋 대상이며, 수치의 원천은 docs/game-design/02-gdd.md 로스터 표다.
extends SceneTree

func _initialize() -> void:
	var exit_code := 0
	if _generate() != OK:
		exit_code = 1
	quit(exit_code)

func _generate() -> Error:
	for dir in ["res://data/skills", "res://data/cells", "res://data/enemies", "res://data/stages"]:
		DirAccess.make_dir_recursive_absolute(dir)

	var skills := {
		&"macrophage_skill": _skill(&"macrophage_skill", "포식 돌진", "주변 적을 끌어당기고 짧게 기절시킵니다.", SkillDef.Kind.PULL_STUN, 7.5, 16.0, 145.0, 58.0, 64.0, 1.15, 0.0),
		&"neutrophil_skill": _skill(&"neutrophil_skill", "염증 폭발", "전방 범위에 폭발 피해를 줍니다.", SkillDef.Kind.AOE_BLAST, 6.0, 42.0, 118.0, 96.0, 0.0, 0.0, 0.0),
		&"b_cell_skill": _skill(&"b_cell_skill", "항체 표식", "가장 위협적인 적에게 받는 피해 증가 표식을 붙입니다.", SkillDef.Kind.MARK, 5.5, 12.0, 70.0, 0.0, 0.0, 0.0, 6.0),
	}
	for skill_id: StringName in skills:
		if _save(skills[skill_id], "res://data/skills/%s.tres" % skill_id) != OK:
			return FAILED

	var cells: Array[CellDef] = [
		_cell(&"macrophage", "대식세포", "전방 제압", "가까운 박테리아를 붙잡고 전선을 밀어냅니다.",
			Color("#28D2A3"), Color("#B6FFE9"), 150.0, 13.0, 88.0, 0.78, 92.0,
			[&"innate", &"frontline", &"phagocytosis"], skills[&"macrophage_skill"],
			"대식세포는 먼저 달려가 침입자를 붙잡는 선천면역의 전방 방어 역할을 모티브로 했습니다."),
		_cell(&"neutrophil", "호중구", "광역 처리", "빠르게 접근해 작은 박테리아 무리를 정리합니다.",
			Color("#F2D95C"), Color("#FFF6B8"), 110.0, 10.0, 102.0, 0.54, 126.0,
			[&"innate", &"frontline", &"inflammatory"], skills[&"neutrophil_skill"],
			"호중구는 빠르게 모여 감염 지점의 작은 침입자를 정리하는 역할을 게임식으로 표현했습니다."),
		_cell(&"b_cell", "B세포", "항체 표식", "강한 박테리아에 항체 표식을 남겨 집중 공격을 돕습니다.",
			Color("#63B3FF"), Color("#D9EEFF"), 95.0, 12.0, 154.0, 0.92, 84.0,
			[&"adaptive", &"ranged", &"antibody"], skills[&"b_cell_skill"],
			"B세포는 항체로 대상을 표식해 면역 반응이 더 정확히 집중되도록 돕는 역할을 모티브로 했습니다."),
	]
	for cell in cells:
		if _save(cell, "res://data/cells/%s.tres" % cell.id) != OK:
			return FAILED

	var enemies := {
		&"bacteria_swarm": _enemy(&"bacteria_swarm", "박테리아 군집", [&"swarm"], 34.0, 36.0, 8.0, 13.0, Color("#F45656")),
		&"armored_bacteria": _enemy(&"armored_bacteria", "두꺼운 박테리아", [&"armored"], 86.0, 22.0, 16.0, 18.0, Color("#C35CFF")),
		&"fast_bacteria": _enemy(&"fast_bacteria", "빠른 침투균", [&"fast"], 24.0, 58.0, 10.0, 11.0, Color("#FF8D42")),
	}
	for enemy_id: StringName in enemies:
		if _save(enemies[enemy_id], "res://data/enemies/%s.tres" % enemy_id) != OK:
			return FAILED

	var stage := StageDef.new()
	stage.id = &"1-1"
	stage.display_name = "1차 방어전"
	stage.base_hp = 120.0
	stage.waves = [
		_wave("1차 침투", [
			_spawn(0.4, enemies[&"bacteria_swarm"], 4, 0.75, 1),
			_spawn(3.4, enemies[&"bacteria_swarm"], 3, 0.8, 0),
			_spawn(6.6, enemies[&"fast_bacteria"], 2, 1.0, 2),
		]),
		_wave("2차 확산", [
			_spawn(0.4, enemies[&"bacteria_swarm"], 5, 0.62, 2),
			_spawn(2.6, enemies[&"armored_bacteria"], 2, 1.8, 1),
			_spawn(6.2, enemies[&"fast_bacteria"], 4, 0.75, 0),
		]),
		_wave("바이오필름 압박", [
			_spawn(0.2, enemies[&"armored_bacteria"], 3, 1.6, 1),
			_spawn(1.8, enemies[&"bacteria_swarm"], 6, 0.55, 0),
			_spawn(4.5, enemies[&"fast_bacteria"], 5, 0.58, 2),
			_spawn(8.0, enemies[&"armored_bacteria"], 1, 1.0, 0),
		]),
	]
	if _save(stage, "res://data/stages/stage_1_1.tres") != OK:
		return FAILED

	print("generated: skills=%d cells=%d enemies=%d stages=1" % [skills.size(), cells.size(), enemies.size()])
	return OK

func _save(res: Resource, path: String) -> Error:
	var err := ResourceSaver.save(res, path)
	if err != OK:
		push_error("save failed: %s (%d)" % [path, err])
		return err
	res.take_over_path(path)
	return OK

func _skill(id: StringName, display_name: String, description: String, kind: SkillDef.Kind, cooldown: float, damage: float, radius: float, forward_offset: float, pull_distance: float, stun_duration: float, mark_duration: float) -> SkillDef:
	var s := SkillDef.new()
	s.id = id
	s.display_name = display_name
	s.description = description
	s.kind = kind
	s.cooldown = cooldown
	s.damage = damage
	s.radius = radius
	s.forward_offset = forward_offset
	s.pull_distance = pull_distance
	s.stun_duration = stun_duration
	s.mark_duration = mark_duration
	return s

func _cell(id: StringName, display_name: String, role: String, description: String, color: Color, accent: Color, hp: float, damage: float, attack_range: float, attack_rate: float, speed: float, tags: Array[StringName], skill: SkillDef, result_copy: String) -> CellDef:
	var c := CellDef.new()
	c.id = id
	c.display_name = display_name
	c.role = role
	c.description = description
	c.color = color
	c.accent = accent
	c.hp = hp
	c.damage = damage
	c.attack_range = attack_range
	c.attack_rate = attack_rate
	c.speed = speed
	c.tags = tags
	c.skill = skill
	c.result_copy = result_copy
	return c

func _enemy(id: StringName, display_name: String, tags: Array[StringName], hp: float, speed: float, base_damage: float, radius: float, color: Color) -> EnemyDef:
	var e := EnemyDef.new()
	e.id = id
	e.display_name = display_name
	e.tags = tags
	e.hp = hp
	e.speed = speed
	e.base_damage = base_damage
	e.radius = radius
	e.color = color
	return e

func _wave(display_name: String, spawns: Array[SpawnEntry]) -> WaveDef:
	var w := WaveDef.new()
	w.display_name = display_name
	w.spawns = spawns
	return w

func _spawn(time: float, enemy: EnemyDef, count: int, spacing: float, lane: int) -> SpawnEntry:
	var entry := SpawnEntry.new()
	entry.time = time
	entry.enemy = enemy
	entry.count = count
	entry.spacing = spacing
	entry.lane = lane
	return entry
