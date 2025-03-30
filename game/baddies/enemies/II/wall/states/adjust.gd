extends EnemyWallState

@export var max_chase_speed: float = 1000.0
@export var min_chase_speed: float = 800.0
@export var max_turn_speed: float = 100.0
@export var min_turn_speed: float = 70.0
@export var give_dist: float = 64.0

@export var steering: Marker2D

var chase_speed: float = 900.0
var turn_speed: float = 70.0

func enter(_msg:={}) -> void:
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	
	enemy.sprite.modulate.a = 0.5
	
	enemy.coll_shape.set_deferred("disabled", true)
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.hit_coll_shape.set_deferred("disabled", true)

func physics_update(delta: float) -> void:
	var target_pos: Vector2 = enemy.player.global_position
	+ ( enemy.player.linear_velocity.normalized() *  give_dist)
	
	var new_transform = steering.global_transform.looking_at(target_pos)
	steering.global_transform = steering.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	enemy.sprite.global_rotation = steering.global_rotation + (PI/2)
	
	enemy.apply_central_force(
		Vector2.from_angle(steering.global_rotation) * chase_speed
	)

func exit() -> void:
	enemy.sprite.modulate.a = 1.0
