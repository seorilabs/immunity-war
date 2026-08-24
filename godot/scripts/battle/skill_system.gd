class_name SkillSystem
## SkillDef.kind 실행 테이블. 리더 스킬 효과를 컨트롤러 상태에 적용한다.

static func execute(skill: SkillDef, controller: BattleController) -> void:
	var leader := controller.leader
	if not is_instance_valid(leader):
		return
	match skill.kind:
		SkillDef.Kind.PULL_STUN:
			var anchor := leader.position + Vector2(skill.forward_offset, 0.0)
			for enemy in controller.registry.alive_enemies():
				if enemy.position.distance_to(leader.position) <= skill.radius:
					enemy.pull_toward(anchor, skill.pull_distance)
					enemy.apply_stun(skill.stun_duration)
					enemy.take_damage(skill.damage, leader.def.id)
			controller.request_fx("ring", leader.position, skill.radius, leader.def.accent, 0.55)
		SkillDef.Kind.AOE_BLAST:
			var center := leader.position + Vector2(skill.forward_offset, 0.0)
			for enemy in controller.registry.alive_enemies():
				if enemy.position.distance_to(center) <= skill.radius:
					enemy.take_damage(skill.damage, leader.def.id)
			controller.request_fx("blast", center, skill.radius, leader.def.accent, 0.45)
		SkillDef.Kind.MARK:
			var target := controller.registry.highest_threat_enemy()
			if is_instance_valid(target):
				target.apply_mark(skill.mark_duration)
				target.take_damage(skill.damage, leader.def.id)
				controller.request_fx("mark", target.position, skill.radius, leader.def.accent, 0.7)
