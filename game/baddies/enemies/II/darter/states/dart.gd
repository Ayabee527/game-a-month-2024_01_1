extends EnemyDarterState

@export var max_darts: int = 5
@export var max_charge_speed: float = 600.0
@export var min_charge_speed: float = 400.0
@export var max_turn_speed: float = 15.0
@export var min_turn_speed: float = 5.0

@export var charge_timer: Timer
@export var charge_vfx: GPUParticles2D

var charge_speed: float = 900.0
var turn_speed: float = 10.0

var darts: int = 0

var adjusting: bool = true

func enter(_msg:={}) -> void:
	charge_speed = randf_range(min_charge_speed, max_charge_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	darts = 0
	
	enemy.hit_coll_shape.set_deferred("disabled", false)
	
	charge_timer.start()

func charge() -> void:
	if is_active:
		enemy.look_at(enemy.player.global_position)
		enemy.apply_central_impulse(
			Vector2.from_angle(enemy.global_rotation) * charge_speed
		)
		charge_timer.start()
		charge_vfx.restart()
		darts += 1

func physics_update(delta: float) -> void:
	var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
	enemy.global_transform = enemy.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)

func exit() -> void:
	enemy.hit_coll_shape.set_deferred("disabled", true)


func _on_charge_timer_timeout() -> void:
	if is_active:
		if adjusting:
			if darts >= max_darts:
				state_machine.transition_to("Vibe")
			else:
				charge()
		else:
			adjusting = true
