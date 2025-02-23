extends EnemyBeybladeState

# Move to a spot that is in the direction the player is moving so you can jump them

@export var ambush_dist: float = 256
@export var ambush_speed: float = 2000

@export var ambush_sfx: AudioStreamPlayer2D

func enter(_msg:={}) -> void:
	ambush_sfx.play()

func physics_update(delta: float) -> void:
	var dist_from_player := enemy.global_position.distance_to(enemy.player.global_position)
	
	if dist_from_player >= ambush_dist:
		var dir_to_ambush := enemy.global_position.direction_to(
			enemy.player.global_position
			+ (enemy.player.linear_velocity.normalized() * 256.0)
		)
		enemy.apply_central_force(
			(dir_to_ambush) * ambush_speed
		)
		
		var dir_to_player := enemy.global_position.direction_to(
			enemy.player.global_position
		)
		
		#print(enemy.player.linear_velocity.normalized().dot(dir_to_player))
		
		if enemy.player.linear_velocity.normalized().dot(dir_to_player) < -0.7:
			state_machine.transition_to("Hunt")
	else:
		var dir_from_player := enemy.player.global_position.direction_to(
			enemy.global_position
		)
		enemy.apply_central_force(
			dir_from_player * ambush_speed
		)


func _on_health_was_hurt(new_health: int, amount: int) -> void:
	if randf() < 0.3:
		state_machine.transition_to("Hunt")
