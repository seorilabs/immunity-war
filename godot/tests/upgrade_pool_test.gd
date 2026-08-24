extends RefCounted
## 강화 3택(CHOOSING_UPGRADE) 검증: 후보 추첨의 결정론, 강화 적용 결과, 선택 전 전투 정지.
## 규격 출처: docs/game-design/02-gdd.md:18·51, docs/game-design/03-ui-ux-spec.md:152~160.

const EPSILON := 0.0001
const FIXED_DELTA := 1.0 / 30.0
const MAX_STEPS := 20000
const IDLE_STEPS := 300  # 10초 방치

static func run(host: Node) -> PackedStringArray:
	var failures := PackedStringArray()
	_check_pool(failures)
	_check_determinism(failures)
	_check_effects(failures)
	_check_battle_flow(failures, host)
	return failures

static func _check_pool(failures: PackedStringArray) -> void:
	var pool := UpgradePool.available([])
	if pool.size() < 6:
		failures.append("강화 풀 부족: %d종 (6종 이상 필요)" % pool.size())
	for upgrade in pool:
		if upgrade.display_name.is_empty() or upgrade.description.is_empty():
			failures.append("강화 표시 정보 누락: %s" % upgrade.id)
		if absf(upgrade.value) <= EPSILON:
			failures.append("강화 수치 0: %s" % upgrade.id)
		if not RunUpgrades.SUPPORTED_KINDS.has(upgrade.effect_kind):
			failures.append("RunUpgrades 미구현 강화가 풀에 있음: %s" % upgrade.id)

static func _check_determinism(failures: PackedStringArray) -> void:
	for wave_index in [1, 2]:
		var first := _ids(UpgradePool.draw(wave_index, 12345, []))
		var second := _ids(UpgradePool.draw(wave_index, 12345, []))
		if first != second:
			failures.append("재표시 시 후보 불일치 (웨이브 %d): %s vs %s" % [wave_index, str(first), str(second)])
		if first.size() != UpgradePool.CHOICE_COUNT:
			failures.append("후보 수 불일치 (웨이브 %d): %d" % [wave_index, first.size()])
		if first.size() != _unique(first).size():
			failures.append("후보 중복 (웨이브 %d): %s" % [wave_index, str(first)])

	var taken: Array[StringName] = _ids(UpgradePool.draw(1, 12345, []))
	for id in _ids(UpgradePool.draw(2, 12345, taken)):
		if taken.has(id):
			failures.append("이미 고른 강화가 후보에 다시 등장: %s" % id)

	var other_seed := _ids(UpgradePool.draw(1, 777, []))
	if other_seed.is_empty():
		failures.append("다른 시드에서 후보가 비었음")

static func _check_effects(failures: PackedStringArray) -> void:
	var upgrades := RunUpgrades.new()
	var untagged: Array[StringName] = []
	var innate_tags: Array[StringName] = [&"innate", &"frontline", &"phagocytosis"]

	upgrades.apply(Db.upgrade(&"u_atk_all"))
	_expect(failures, "u_atk_all 공격력 배율", upgrades.damage_mult_for(untagged), 1.10)
	_expect(failures, "u_atk_all 반영 피해(100)",
		CombatRules.final_damage(100.0, untagged, untagged, false, upgrades.damage_mult_for(untagged)), 110.0)

	upgrades.apply(Db.upgrade(&"u_atk_innate"))
	_expect(failures, "u_atk_innate 태그 한정 배율", upgrades.damage_mult_for(innate_tags), 1.265)
	_expect(failures, "u_atk_innate 비대상 태그 불변", upgrades.damage_mult_for(untagged), 1.10)

	upgrades.apply(Db.upgrade(&"u_mark_bonus"))
	_expect(failures, "u_mark_bonus 표식 피해(100)",
		CombatRules.final_damage(100.0, untagged, untagged, true, 1.0, 1.0, upgrades.mark_bonus), 170.0)

	upgrades.apply(Db.upgrade(&"u_atkspd_all"))
	_expect(failures, "u_atkspd_all 공격 주기 배율", upgrades.attack_rate_mult, 0.9)
	upgrades.apply(Db.upgrade(&"u_skill_cd"))
	_expect(failures, "u_skill_cd 쿨다운 배율", upgrades.skill_cooldown_mult, 0.8)
	upgrades.apply(Db.upgrade(&"u_base_regen"))
	_expect(failures, "u_base_regen 웨이브 회복량", upgrades.base_regen_per_wave, 12.0)
	upgrades.apply(Db.upgrade(&"u_reinforce_charge"))
	_expect(failures, "u_reinforce_charge 충전 배율", upgrades.reinforce_charge_mult, 1.25)
	upgrades.apply(Db.upgrade(&"u_slow_aura"))
	_expect(failures, "u_slow_aura 오라 감쇠", upgrades.slow_aura_factor, 0.25)
	upgrades.apply(Db.upgrade(&"u_wave_shield"))
	_expect(failures, "u_wave_shield 실드량", upgrades.wave_shield, 30.0)
	upgrades.apply(Db.upgrade(&"u_crit"))
	_expect(failures, "u_crit 확률", upgrades.crit_chance, 0.15)

	if upgrades.taken.size() != 10:
		failures.append("보유 강화 누적 실패: %s" % str(upgrades.taken))

static func _check_battle_flow(failures: PackedStringArray, host: Node) -> void:
	var world := Node2D.new()
	host.add_child(world)

	var config := BattleConfig.new()
	config.stage = Db.stage(&"1-1")
	config.rng_seed = 12345
	config.roster = [Db.cell(&"macrophage")]
	for teammate_id in Db.teammate_ids(&"macrophage"):
		config.roster.append(Db.cell(teammate_id))
	var controller := BattleController.new(config, world)
	controller.start()

	var steps := 0
	while (controller.state == BattleController.State.RUNNING or controller.state == BattleController.State.BETWEEN_WAVES) and steps < MAX_STEPS:
		controller.step(FIXED_DELTA)
		if controller.can_use_skill():
			controller.use_leader_skill()
		steps += 1

	if controller.state != BattleController.State.CHOOSING_UPGRADE:
		failures.append("웨이브 1 클리어 후 CHOOSING_UPGRADE 진입 실패 (state=%d)" % controller.state)
		_teardown(host, world)
		return
	if controller.wave_index != 0:
		failures.append("강화 진입 시 웨이브 인덱스 이상: %d" % controller.wave_index)
	if controller.upgrade_choices.size() != UpgradePool.CHOICE_COUNT:
		failures.append("전투 중 후보 수 이상: %d" % controller.upgrade_choices.size())

	# 선택 전 방치: 스폰·타이머·유닛이 전부 멈춰 있어야 한다.
	var frozen_elapsed := controller.elapsed
	var frozen_wave := controller.wave_index
	for i in range(IDLE_STEPS):
		controller.step(FIXED_DELTA)
	if controller.state != BattleController.State.CHOOSING_UPGRADE:
		failures.append("미선택 방치 중 상태가 바뀜 (state=%d)" % controller.state)
	if controller.wave_index != frozen_wave:
		failures.append("미선택 방치 중 다음 웨이브 시작됨 (wave=%d)" % controller.wave_index)
	if absf(controller.elapsed - frozen_elapsed) > EPSILON:
		failures.append("미선택 방치 중 전투 시간이 흐름 (%.2f → %.2f)" % [frozen_elapsed, controller.elapsed])
	if not controller.registry.enemies.is_empty():
		failures.append("미선택 방치 중 적이 스폰됨 (%d)" % controller.registry.enemies.size())

	var offered := _ids(controller.upgrade_choices)
	if not controller.choose_upgrade(99):
		pass
	else:
		failures.append("범위 밖 인덱스가 수락됨")
	if _ids(controller.upgrade_choices) != offered:
		failures.append("잘못된 선택 후 후보가 바뀜")

	var picked_id: StringName = controller.upgrade_choices[0].id
	if not controller.choose_upgrade(0):
		failures.append("강화 선택이 거부됨")
	if controller.state != BattleController.State.RUNNING:
		failures.append("강화 선택 후 RUNNING 복귀 실패 (state=%d)" % controller.state)
	if controller.wave_index != 1:
		failures.append("강화 선택 후 다음 웨이브 미시작 (wave=%d)" % controller.wave_index)
	if not controller.run_upgrades.has(picked_id):
		failures.append("선택한 강화가 런 누적값에 없음: %s" % picked_id)

	# 마지막 웨이브 클리어는 강화 없이 곧바로 결과로 간다.
	steps = 0
	while controller.state != BattleController.State.FINISHED and steps < MAX_STEPS:
		controller.step(FIXED_DELTA)
		if controller.state == BattleController.State.CHOOSING_UPGRADE:
			if controller.wave_index >= controller.stage().waves.size() - 1:
				failures.append("마지막 웨이브 후 강화 화면이 표시됨")
				break
			controller.choose_upgrade(0)
		if controller.can_use_skill():
			controller.use_leader_skill()
		steps += 1
	if controller.state != BattleController.State.FINISHED:
		failures.append("강화 3택 경로로 전투가 %d스텝 안에 종료되지 않음 (state=%d wave=%d)" % [MAX_STEPS, controller.state, controller.wave_index])
	if controller.run_upgrades.taken.size() != controller.stage().waves.size() - 1:
		failures.append("웨이브 사이 강화 횟수 이상: %s (웨이브 %d개)" % [str(controller.run_upgrades.taken), controller.stage().waves.size()])

	_teardown(host, world)

static func _teardown(host: Node, world: Node2D) -> void:
	host.remove_child(world)
	world.queue_free()

static func _ids(upgrades: Array[UpgradeDef]) -> Array[StringName]:
	var ids: Array[StringName] = []
	for upgrade in upgrades:
		ids.append(upgrade.id)
	return ids

static func _unique(ids: Array[StringName]) -> Array[StringName]:
	var seen: Array[StringName] = []
	for id in ids:
		if not seen.has(id):
			seen.append(id)
	return seen

static func _expect(failures: PackedStringArray, label: String, actual: float, expected: float) -> void:
	if absf(actual - expected) > EPSILON:
		failures.append("%s: 기대 %s, 실제 %s" % [label, expected, actual])
