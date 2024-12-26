extends EnemyHopperState

@export var max_hop_distance: float = 128.0

@export var time_to_peak: float = 0.5
@export var time_to_fall: float = 0.4

@export var max_chase_speed: float = 1000.0
@export var min_chase_speed: float = 600.0
@export var max_turn_speed: float = 15.0
@export var min_turn_speed: float = 5.0

@export var hop_timer: Timer

var turn_speed: float
var chase_speed: float

func enter(_msg:={}) -> void:
	#var dir_to_target = enemy.global_position.direction_to(enemy.player.global_position)
	#var angle_to = Vector2.RIGHT.angle_to(dir_to_target)
	#angle_to += deg_to_rad(randf_range(-max_turn, max_turn))
	
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	
	hop()

func physics_update(delta: float) -> void:
	if not hop_timer.is_stopped():
		var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
		enemy.global_transform = enemy.global_transform.interpolate_with(
			new_transform, turn_speed * delta
		)

func hop() -> void:
	enemy.sprite.squish(
		0.5, 4.0, true, true
	)
	var total_time: float = time_to_peak + time_to_fall
	#var jump_distance: float = randf_range(min_leap_distance, max_leap_distance)
	var jump_distance: float = enemy.global_position.distance_to(
		enemy.player.global_position + Vector2(
			randf_range(-32.0, 32.0),
			randf_range(-32.0, 32.0),
		)
	) / 2.0
	jump_distance = min(jump_distance, max_hop_distance)
	
	var jump_velocity: float = jump_distance / ( 0.5 * total_time )
	
	enemy.sprite.jump(48.0, time_to_peak, time_to_fall)
	enemy.linear_damp = 0.0
	enemy.apply_central_impulse( Vector2.from_angle(enemy.global_rotation) * jump_velocity )


func _on_height_sprite_ground_hit() -> void:
	if is_active:
		enemy.bleeder.bleed(1, 1.0, 10)
		enemy.weapon_handler.shoot()
		enemy.linear_velocity = Vector2.ZERO
		hop_timer.start()
		enemy.linear_damp = 2.5


func _on_hop_cooldown_timeout() -> void:
	if is_active:
		hop()
