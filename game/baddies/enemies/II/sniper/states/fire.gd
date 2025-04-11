extends EnemySniperState

@export var turn_speed: float = 2.0

var tween: Tween

func enter(_msg:={}) -> void:
	enemy.laser_warning.active = true
	#enemy.weapon_handler.firing = true

func physics_update(delta: float) -> void:
	var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
	enemy.global_transform = enemy.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	if enemy.player.global_position.distance_to(enemy.global_position) < 92.0:
		state_machine.transition_to("Flee")
	
	if enemy.player.global_position.distance_to(enemy.global_position) > 384.0:
		state_machine.transition_to("Chase")

func exit() -> void:
	#enemy.weapon_handler.firing = false
	enemy.laser_warning.active = false
	#tween.stop()

func _on_health_was_hurt(new_health: int, amount: int) -> void:
	if is_active and enemy.player.global_position.distance_to(
		enemy.global_position
	) < 160.0:
		if randf() < 0.75:
			state_machine.transition_to("Flee")


func _on_weapon_handler_fired() -> void:
	pass
	#tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(
		#enemy, "warn_size", 4.0, 2.0
	#).from(0.0)
	#enemy.laser_warning.active = true


func _on_laser_warning_fired() -> void:
	enemy.weapon_handler.shoot()
