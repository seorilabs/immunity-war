extends Node
## 화면 간 공유 상태와 시그널 허브. Phase 1은 리더 선택·전투 결과 전달만 담당한다.

var selected_leader: StringName = &"macrophage"
var current_stage_id: StringName = &"1-1"
var last_summary: Dictionary = {}
