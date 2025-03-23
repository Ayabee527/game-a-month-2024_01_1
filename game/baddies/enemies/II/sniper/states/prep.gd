extends EnemySniperState

@export var turn_speed: float = 4.0

@export var prep_timer: Timer

var tween: Tween

func enter(_msg:={}) -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		enemy, "warn_size", 4.0, 0.2
	)
	
	prep_timer.start()

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
	tween.stop()

func _on_health_was_hurt(new_health: int, amount: int) -> void:
	if is_active and enemy.player.global_position.distance_to(
		enemy.global_position
	) < 160.0:
		if randf() < 0.5:
			state_machine.transition_to("Flee")


func _on_prep_timer_timeout() -> void:
	if is_active:
		state_machine.transition_to("Fire")
