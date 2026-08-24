class_name AnalyticsPort
extends RefCounted
## 분석 이벤트 송출 포트. 기본 구현은 no-op(+디버그 로그)이라 네트워크 없이도 전투가 정상 동작한다.
## GA4 Measurement Protocol 어댑터는 측정 ID·api_secret 확정 후 이 포트를 상속해 교체한다.
## (AGENTS.md 구조 원칙: 플랫폼 SDK는 scripts/services/ 의 Backend 어댑터 뒤에 격리한다)

## 이벤트 이름 — 호출부에 문자열 리터럴을 두지 않는다.
const EVENT_LEVEL_START := "level_start"
const EVENT_WAVE_REACHED := "wave_reached"
const EVENT_SKILL_USED := "skill_used"
const EVENT_LEVEL_END := "level_end"
const EVENT_UPGRADE_PICKED := "upgrade_picked"
const EVENT_REINFORCE_USED := "reinforce_used"

## 파라미터 키
const PARAM_LEADER_ID := "leader_id"
const PARAM_STAGE_ID := "stage_id"
const PARAM_WAVE := "wave"
const PARAM_ELAPSED := "elapsed"
const PARAM_SUCCESS := "success"
const PARAM_REASON := "reason"
const PARAM_DEFEATED := "defeated"
const PARAM_BASE_HP := "base_hp"
const PARAM_UPGRADE_ID := "upgrade_id"
const PARAM_CELL_ID := "cell_id"

func track(event_name: String, params: Dictionary) -> void:
	if OS.is_debug_build():
		print("[analytics] %s %s" % [event_name, JSON.stringify(params)])
