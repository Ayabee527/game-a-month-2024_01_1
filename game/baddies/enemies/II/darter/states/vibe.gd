extends EnemyDarterState

@export var max_chase_speed: float = 400.0
@export var min_chase_speed: float = 200.0
@export var max_turn_speed: float = 10.0
@export var min_turn_speed: float = 1.0

@export var vibe_timer: Timer

var turn_speed: float = 2.0
var chase_speed: float = 300.0

func enter(_msg:={}) -> void:
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	
	vibe_timer.start()

func physics_update(delta: float) -> void:
	var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
	enemy.global_transform = enemy.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	enemy.apply_central_force(
		Vector2.from_angle(enemy.global_rotation) * chase_speed
	)

func exit() -> void:
	pass


func _on_vibe_timer_timeout() -> void:
	state_machine.transition_to("Dart")
