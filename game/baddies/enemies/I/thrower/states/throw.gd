extends EnemyThrowerState

@export var max_chase_speed: float = 1000.0
@export var min_chase_speed: float = 600.0
@export var max_turn_speed: float = 15.0
@export var min_turn_speed: float = 5.0

var turn_speed: float = 10.0
var chase_speed: float = 500.0

func enter(_msg:={}) -> void:
	enemy.weapon_handler.firing = true
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	chase_speed = randf_range(min_chase_speed, max_chase_speed)

func physics_update(delta: float) -> void:
	var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
	enemy.global_transform = enemy.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	enemy.apply_central_force(
		Vector2.from_angle(enemy.global_rotation) * chase_speed
	)

func exit() -> void:
	enemy.weapon_handler.firing = false
