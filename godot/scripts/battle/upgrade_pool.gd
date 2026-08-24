class_name UpgradePool
## 웨이브 사이 강화 3택 후보 추첨. 같은 (전투 시드, 웨이브 인덱스, 보유 강화) 면 항상 같은 조합이 나온다.
## rarity 가중: COMMON 3 : RARE 1 (05-economy 콘텐츠 재고).

const CHOICE_COUNT := 3
const WAVE_SEED_STRIDE := 7919
const COMMON_WEIGHT := 3.0
const RARE_WEIGHT := 1.0

## 이미 고른 강화는 후보에서 빠진다. 남은 후보가 3개 미만이면 남은 만큼만 반환한다.
static func draw(wave_index: int, battle_seed: int, taken: Array[StringName]) -> Array[UpgradeDef]:
	var candidates := available(taken)
	var rng := RandomNumberGenerator.new()
	rng.seed = battle_seed + wave_index * WAVE_SEED_STRIDE

	var picked: Array[UpgradeDef] = []
	while not candidates.is_empty() and picked.size() < CHOICE_COUNT:
		var total := 0.0
		for upgrade in candidates:
			total += _weight(upgrade)
		var roll := rng.randf() * total
		var acc := 0.0
		var chosen := candidates.size() - 1
		for i in range(candidates.size()):
			acc += _weight(candidates[i])
			if roll <= acc:
				chosen = i
				break
		picked.append(candidates[chosen])
		candidates.remove_at(chosen)
	return picked

## id 오름차순 고정 목록 — Dictionary 순회 순서에 추첨이 흔들리지 않게 한다.
static func available(taken: Array[StringName]) -> Array[UpgradeDef]:
	var ids := Db.upgrade_order.duplicate()
	ids.sort()
	var result: Array[UpgradeDef] = []
	for id: StringName in ids:
		if taken.has(id):
			continue
		var upgrade := Db.upgrade(id)
		if upgrade != null and RunUpgrades.SUPPORTED_KINDS.has(upgrade.effect_kind):
			result.append(upgrade)
	return result

static func _weight(upgrade: UpgradeDef) -> float:
	return RARE_WEIGHT if upgrade.rarity == UpgradeDef.Rarity.RARE else COMMON_WEIGHT
