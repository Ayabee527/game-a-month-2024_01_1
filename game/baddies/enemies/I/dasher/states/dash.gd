extends EnemyDasherState

@export var warn_time: float = 0.5

@export var min_dash_speed: float = 800.0
@export var max_dash_speed: float = 600.0

@export var max_turn_speed: float = 30.0
@export var min_turn_speed: float = 15.0

@export var dash_timer: Timer
@export var dash_particles: GPUParticles2D

var turn_speed: float
var dash_speed: float

func enter(_msg:={}) -> void:
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	dash_speed = randf_range(min_dash_speed, max_dash_speed)
	
	dash_timer.start()
	dash()

func physics_update(delta: float) -> void:
	if enemy.hit_coll_shape.disabled:
		var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
		enemy.global_transform = enemy.global_transform.interpolate_with(
			new_transform, turn_speed * delta
		)
	
	if enemy.linear_velocity.length() < 128.0 and not enemy.hit_coll_shape.disabled:
		enemy.hit_coll_shape.set_deferred("disabled", true)

func dash() -> void:
	enemy.sprite.modulate = Color.WHITE
	enemy.trail.modulate = Color.WHITE
	enemy.sprite.squish(
		warn_time, 4.0, true, false
	)
	
	await get_tree().create_timer(warn_time, false).timeout
	
	enemy.linear_velocity = Vector2.ZERO
	enemy.sprite.squish(
		warn_time, 4.0, true, true
	)
	enemy.sprite.modulate = enemy.default_color
	enemy.trail.modulate = enemy.default_color
	enemy.hit_coll_shape.set_deferred("disabled", false)
	enemy.apply_central_impulse(
		Vector2.from_angle(enemy.global_rotation) * dash_speed
	)
	dash_particles.restart()


func _on_dash_timer_timeout() -> void:
	if is_active:
		dash()
