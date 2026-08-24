# 정적 데이터(.tres) 생성기. 실행:
#   godot --headless --path godot -s tools/gen_static_data.gd
# 생성물은 커밋 대상이며, 수치의 원천은 docs/game-design/02-gdd.md 로스터·상성 표와 05 경제 문서다.
# 웨이브 스펙 표기: [time, 적키, count, spacing, lane]
extends SceneTree

var _enemies: Dictionary = {}

func _initialize() -> void:
	var exit_code := 0
	if _generate() != OK:
		exit_code = 1
	quit(exit_code)

func _generate() -> Error:
	for dir in ["res://data/skills", "res://data/cells", "res://data/enemies", "res://data/stages", "res://data/chapters", "res://data/upgrades"]:
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

	_enemies = {
		&"swarm": _enemy(&"bacteria_swarm", "박테리아 군집", [&"swarm"], 34.0, 36.0, 8.0, 13.0, Color("#F45656")),
		&"armored": _enemy(&"armored_bacteria", "두꺼운 박테리아", [&"armored"], 86.0, 22.0, 16.0, 18.0, Color("#C35CFF")),
		&"fast": _enemy(&"fast_bacteria", "빠른 침투균", [&"fast"], 24.0, 58.0, 10.0, 11.0, Color("#FF8D42")),
	}
	for enemy_key: StringName in _enemies:
		var enemy: EnemyDef = _enemies[enemy_key]
		if _save(enemy, "res://data/enemies/%s.tres" % enemy.id) != OK:
			return FAILED

	var upgrades: Array[UpgradeDef] = [
		_upgrade(&"u_atk_innate", "선천 면역 강화", "선천면역 세포 공격력 +15%", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.STAT_MULT_DAMAGE, &"innate", 0.15),
		_upgrade(&"u_atk_adaptive", "적응 면역 강화", "적응면역 세포 공격력 +15%", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.STAT_MULT_DAMAGE, &"adaptive", 0.15),
		_upgrade(&"u_atk_all", "면역 활성화", "모든 세포 공격력 +10%", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.STAT_MULT_DAMAGE, &"", 0.10),
		_upgrade(&"u_atkspd_all", "반응 속도 향상", "모든 세포 공격 속도 +10%", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.STAT_MULT_ATTACK_RATE, &"", 0.10),
		_upgrade(&"u_mark_bonus", "옵소닌화 증폭", "표식 피해 계수 +0.25", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.MARK_BONUS, &"", 0.25),
		_upgrade(&"u_skill_cd", "신호 전달 가속", "리더 스킬 쿨다운 -20%", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.SKILL_CD_MULT, &"", 0.20),
		_upgrade(&"u_base_regen", "조직 재생", "웨이브 시작 시 기지 HP +12", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.BASE_REGEN, &"", 12.0),
		_upgrade(&"u_reinforce_charge", "골수 동원", "증원 게이지 충전 +25%", UpgradeDef.Rarity.COMMON, UpgradeDef.EffectKind.REINFORCE_CHARGE, &"", 0.25),
		_upgrade(&"u_wave_shield", "점막 방벽", "웨이브 시작 시 기지 실드 30", UpgradeDef.Rarity.RARE, UpgradeDef.EffectKind.WAVE_SHIELD, &"", 30.0),
		_upgrade(&"u_slow_aura", "점액 분비", "경계 근처 적 이동 속도 -25%", UpgradeDef.Rarity.RARE, UpgradeDef.EffectKind.SLOW_AURA, &"", 0.25),
		_upgrade(&"u_crit", "정밀 타격", "15% 확률로 피해 2배", UpgradeDef.Rarity.RARE, UpgradeDef.EffectKind.CRIT, &"", 0.15),
	]
	for upgrade in upgrades:
		if _save(upgrade, "res://data/upgrades/%s.tres" % upgrade.id) != OK:
			return FAILED

	var stages: Array[StageDef] = [
		_stage(&"1-1", "첫 번째 침투", 1, 1.0, [
			[[0.4, &"swarm", 4, 0.75, 1], [3.4, &"swarm", 3, 0.8, 0], [6.6, &"fast", 2, 1.0, 2]],
			[[0.4, &"swarm", 5, 0.62, 2], [2.6, &"armored", 2, 1.8, 1], [6.2, &"fast", 4, 0.75, 0]],
			[[0.2, &"armored", 3, 1.6, 1], [1.8, &"swarm", 6, 0.55, 0], [4.5, &"fast", 5, 0.58, 2], [8.0, &"armored", 1, 1.0, 0]],
		]),
		_stage(&"1-2", "표피 돌파 시도", 2, 1.0, [
			[[0.4, &"swarm", 5, 0.7, 1], [4.0, &"fast", 3, 0.9, 0]],
			[[0.3, &"swarm", 4, 0.7, 2], [3.0, &"fast", 4, 0.7, 1], [6.0, &"swarm", 3, 0.6, 0]],
			[[0.5, &"armored", 2, 1.8, 1], [2.0, &"swarm", 6, 0.6, 2], [5.5, &"fast", 4, 0.6, 0]],
		]),
		_stage(&"1-3", "모세혈관 접근", 3, 1.1, [
			[[0.3, &"swarm", 6, 0.6, 1], [4.5, &"fast", 3, 0.8, 2]],
			[[0.4, &"armored", 2, 1.6, 0], [2.2, &"swarm", 5, 0.6, 1]],
			[[0.3, &"fast", 6, 0.55, 2], [4.0, &"swarm", 4, 0.6, 0]],
			[[0.4, &"armored", 3, 1.5, 1], [2.5, &"swarm", 6, 0.5, 2], [6.0, &"fast", 4, 0.6, 0]],
		]),
		_stage(&"1-4", "각질층 붕괴", 4, 1.15, [
			[[0.3, &"swarm", 6, 0.55, 0], [3.5, &"fast", 4, 0.7, 1]],
			[[0.3, &"armored", 3, 1.4, 2], [2.0, &"swarm", 5, 0.55, 1]],
			[[0.3, &"armored", 2, 1.5, 0], [2.0, &"fast", 6, 0.5, 2], [5.0, &"swarm", 4, 0.55, 1]],
			[[0.3, &"armored", 4, 1.3, 1], [2.0, &"swarm", 8, 0.45, 0], [6.0, &"fast", 5, 0.5, 2]],
		]),
		_stage(&"1-5", "침투 가속", 5, 1.2, [
			[[0.3, &"fast", 6, 0.5, 1], [3.0, &"swarm", 4, 0.6, 0]],
			[[0.3, &"fast", 5, 0.5, 2], [2.5, &"fast", 5, 0.5, 0], [5.0, &"swarm", 4, 0.55, 1]],
			[[0.3, &"armored", 3, 1.4, 1], [2.0, &"fast", 6, 0.45, 2]],
			[[0.3, &"swarm", 8, 0.45, 0], [3.0, &"armored", 3, 1.3, 1], [6.0, &"fast", 6, 0.45, 2]],
		]),
		_stage(&"1-6", "각화 군체", 6, 1.3, [
			[[0.3, &"swarm", 6, 0.5, 1], [3.0, &"armored", 2, 1.5, 0]],
			[[0.3, &"armored", 4, 1.2, 1], [2.5, &"swarm", 5, 0.5, 2]],
			[[0.3, &"fast", 7, 0.45, 0], [3.0, &"swarm", 5, 0.5, 1]],
			[[0.3, &"armored", 4, 1.2, 2], [2.0, &"swarm", 6, 0.45, 1], [4.0, &"armored", 3, 1.2, 0]],
			[[0.3, &"armored", 5, 1.1, 1], [2.0, &"swarm", 8, 0.4, 0], [5.0, &"fast", 6, 0.45, 2]],
		]),
		_stage(&"1-7", "경계 총공세", 7, 1.35, [
			[[0.3, &"swarm", 7, 0.5, 2], [3.0, &"fast", 4, 0.6, 1]],
			[[0.3, &"armored", 3, 1.3, 0], [2.0, &"fast", 5, 0.5, 2], [4.5, &"swarm", 5, 0.5, 1]],
			[[0.3, &"armored", 4, 1.2, 1], [2.0, &"swarm", 7, 0.45, 0]],
			[[0.3, &"fast", 8, 0.4, 2], [3.0, &"armored", 3, 1.2, 1], [5.0, &"swarm", 6, 0.45, 0]],
			[[0.3, &"armored", 5, 1.1, 0], [2.0, &"fast", 6, 0.45, 1], [4.0, &"swarm", 9, 0.4, 2], [8.0, &"armored", 2, 1.2, 2]],
		]),
	]
	for stage in stages:
		if _save(stage, "res://data/stages/stage_%s.tres" % String(stage.id).replace("-", "_")) != OK:
			return FAILED

	var chapter := ChapterDef.new()
	chapter.id = &"ch1"
	chapter.display_name = "상처 피부"
	chapter.stages = stages
	if _save(chapter, "res://data/chapters/chapter_1.tres") != OK:
		return FAILED

	print("generated: skills=%d cells=%d enemies=%d upgrades=%d stages=%d chapters=1" % [skills.size(), cells.size(), _enemies.size(), upgrades.size(), stages.size()])
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

func _upgrade(id: StringName, display_name: String, description: String, rarity: UpgradeDef.Rarity, effect_kind: UpgradeDef.EffectKind, target_tag: StringName, value: float) -> UpgradeDef:
	var u := UpgradeDef.new()
	u.id = id
	u.display_name = display_name
	u.description = description
	u.rarity = rarity
	u.effect_kind = effect_kind
	u.target_tag = target_tag
	u.value = value
	return u

func _stage(id: StringName, display_name: String, order: int, hp_mult: float, wave_specs: Array) -> StageDef:
	var stage := StageDef.new()
	stage.id = id
	stage.display_name = display_name
	stage.order = order
	stage.hp_mult = hp_mult
	stage.base_hp = 120.0
	var waves: Array[WaveDef] = []
	for wave_index in range(wave_specs.size()):
		var spawns: Array[SpawnEntry] = []
		for spec: Array in wave_specs[wave_index]:
			var entry := SpawnEntry.new()
			entry.time = float(spec[0])
			entry.enemy = _enemies[spec[1]]
			entry.count = int(spec[2])
			entry.spacing = float(spec[3])
			entry.lane = int(spec[4])
			spawns.append(entry)
		var wave := WaveDef.new()
		wave.display_name = "%d차 침투" % (wave_index + 1)
		wave.spawns = spawns
		waves.append(wave)
	stage.waves = waves
	return stage
