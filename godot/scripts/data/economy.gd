class_name Economy
## 경제 공식의 단일 소유처. 수치 원천은 docs/game-design/05-economy-content-liveops.md 밸런스 모델.

const LEVEL_MAX := 10
const LEVEL_COST_BASE := 40.0
const LEVEL_COST_GROWTH := 1.6
const REWARD_BASE := 18
const REWARD_SLOPE := 6
const FIRST_CLEAR_MULT := 3
const BOSS_CLEAR_MULT := 5

## 전역 스테이지 순번(order, 1부터)에 대한 반복 클리어 보상.
static func reward_base(order: int) -> int:
	return REWARD_BASE + REWARD_SLOPE * order

static func reward_first(order: int, is_boss: bool) -> int:
	return reward_base(order) * (BOSS_CLEAR_MULT if is_boss else FIRST_CLEAR_MULT)

## lv → lv+1 비용. lv는 현재 레벨(1~9).
static func level_up_cost(level: int) -> int:
	return int(floor(LEVEL_COST_BASE * pow(LEVEL_COST_GROWTH, float(level - 1))))
