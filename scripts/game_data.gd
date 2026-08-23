extends RefCounted
class_name GameData

const CELLS := {
	"macrophage": {
		"name": "대식세포",
		"role": "전방 제압",
		"desc": "가까운 박테리아를 붙잡고 전선을 밀어냅니다.",
		"skill_name": "포식 돌진",
		"skill_desc": "주변 적을 끌어당기고 짧게 기절시킵니다.",
		"color": Color("#28D2A3"),
		"accent": Color("#B6FFE9"),
		"hp": 150.0,
		"damage": 13.0,
		"range": 88.0,
		"attack_rate": 0.78,
		"speed": 92.0,
		"cooldown": 7.5
	},
	"neutrophil": {
		"name": "호중구",
		"role": "광역 처리",
		"desc": "빠르게 접근해 작은 박테리아 무리를 정리합니다.",
		"skill_name": "염증 폭발",
		"skill_desc": "전방 범위에 폭발 피해를 줍니다.",
		"color": Color("#F2D95C"),
		"accent": Color("#FFF6B8"),
		"hp": 110.0,
		"damage": 10.0,
		"range": 102.0,
		"attack_rate": 0.54,
		"speed": 126.0,
		"cooldown": 6.0
	},
	"b_cell": {
		"name": "B세포",
		"role": "항체 표식",
		"desc": "강한 박테리아에 항체 표식을 남겨 집중 공격을 돕습니다.",
		"skill_name": "항체 표식",
		"skill_desc": "가장 위협적인 적에게 받는 피해 증가 표식을 붙입니다.",
		"color": Color("#63B3FF"),
		"accent": Color("#D9EEFF"),
		"hp": 95.0,
		"damage": 12.0,
		"range": 154.0,
		"attack_rate": 0.92,
		"speed": 84.0,
		"cooldown": 5.5
	}
}

const ENEMIES := {
	"bacteria_swarm": {
		"name": "박테리아 군집",
		"hp": 34.0,
		"speed": 36.0,
		"damage": 8.0,
		"color": Color("#F45656"),
		"radius": 13.0
	},
	"armored_bacteria": {
		"name": "두꺼운 박테리아",
		"hp": 86.0,
		"speed": 22.0,
		"damage": 16.0,
		"color": Color("#C35CFF"),
		"radius": 18.0
	},
	"fast_bacteria": {
		"name": "빠른 침투균",
		"hp": 24.0,
		"speed": 58.0,
		"damage": 10.0,
		"color": Color("#FF8D42"),
		"radius": 11.0
	}
}

const WAVES := [
	{
		"name": "1차 침투",
		"spawns": [
			{"time": 0.4, "enemy": "bacteria_swarm", "count": 4, "spacing": 0.75, "lane": 1},
			{"time": 3.4, "enemy": "bacteria_swarm", "count": 3, "spacing": 0.8, "lane": 0},
			{"time": 6.6, "enemy": "fast_bacteria", "count": 2, "spacing": 1.0, "lane": 2}
		]
	},
	{
		"name": "2차 확산",
		"spawns": [
			{"time": 0.4, "enemy": "bacteria_swarm", "count": 5, "spacing": 0.62, "lane": 2},
			{"time": 2.6, "enemy": "armored_bacteria", "count": 2, "spacing": 1.8, "lane": 1},
			{"time": 6.2, "enemy": "fast_bacteria", "count": 4, "spacing": 0.75, "lane": 0}
		]
	},
	{
		"name": "바이오필름 압박",
		"spawns": [
			{"time": 0.2, "enemy": "armored_bacteria", "count": 3, "spacing": 1.6, "lane": 1},
			{"time": 1.8, "enemy": "bacteria_swarm", "count": 6, "spacing": 0.55, "lane": 0},
			{"time": 4.5, "enemy": "fast_bacteria", "count": 5, "spacing": 0.58, "lane": 2},
			{"time": 8.0, "enemy": "armored_bacteria", "count": 1, "spacing": 1.0, "lane": 0}
		]
	}
]

const RESULT_COPY := {
	"macrophage": "대식세포는 먼저 달려가 침입자를 붙잡는 선천면역의 전방 방어 역할을 모티브로 했습니다.",
	"neutrophil": "호중구는 빠르게 모여 감염 지점의 작은 침입자를 정리하는 역할을 게임식으로 표현했습니다.",
	"b_cell": "B세포는 항체로 대상을 표식해 면역 반응이 더 정확히 집중되도록 돕는 역할을 모티브로 했습니다."
}

static func teammate_ids(leader_id: String) -> Array:
	var ids := ["macrophage", "neutrophil", "b_cell"]
	ids.erase(leader_id)
	return ids

