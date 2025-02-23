extends EnemyBeybladeState

# Once in position, charge at the player until off screen or chasing too long

@export var max_chase_speed: float = 1200.0
@export var min_chase_speed: float = 800.0
@export var max_turn_speed: float = 15.0
@export var min_turn_speed: float = 5.0

@export var steering: Marker2D
@export var hunt_timer: Timer
@export var hunt_sfx: AudioStreamPlayer2D

var turn_speed: float = 0.0
var chase_speed: float = 0.0

func enter(_msg:={}) -> void:
	if turn_speed == 0.0:
		turn_speed = randf_range(min_turn_speed, max_turn_speed)
	if chase_speed == 0.0:
		chase_speed = randf_range(min_chase_speed, max_chase_speed)
	hunt_timer.start()
	hunt_sfx.play()

func physics_update(delta: float) -> void:
	var new_transform = steering.global_transform.looking_at(enemy.player.global_position)
	steering.global_transform = steering.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	enemy.apply_central_force(
		Vector2.from_angle(steering.global_rotation) * chase_speed
	)

func exit() -> void:
	hunt_timer.stop()


func _on_hunt_hide_screen_exited() -> void:
	if is_active:
		state_machine.transition_to("Ambush")


func _on_hunt_timer_timeout() -> void:
	if is_active:
		state_machine.transition_to("Ambush")


func _on_health_was_hurt(new_health: int, amount: int) -> void:
	if randf() < 0.3:
		state_machine.transition_to("Ambush")
