class_name ArenaLayout
## 전장 좌표 규칙. 수치는 프로토타입 검증값 유지 (02-gdd CON-007 주변 상수).

const BASE_X := 58.0

static func lane_y(arena_size: Vector2, lane: int) -> float:
	return lerpf(210.0, arena_size.y - 246.0, float(lane) / 2.0)

static func clamp_to_arena(arena_size: Vector2, point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, BASE_X + 34.0, arena_size.x - 54.0),
		clampf(point.y, 138.0, arena_size.y - 154.0)
	)

static func spawn_position(arena_size: Vector2, lane: int, rng: RandomNumberGenerator) -> Vector2:
	return Vector2(
		arena_size.x + 42.0 + rng.randf_range(0.0, 24.0),
		lane_y(arena_size, lane) + rng.randf_range(-18.0, 18.0)
	)

static func cell_home(arena_size: Vector2, slot: int) -> Vector2:
	match slot:
		0:
			return Vector2(106.0, lane_y(arena_size, 1))
		1:
			return Vector2(94.0, lane_y(arena_size, 0))
		_:
			return Vector2(96.0, lane_y(arena_size, 2))
