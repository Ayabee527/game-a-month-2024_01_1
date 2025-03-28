extends EnemyMoleState

@export var max_chase_speed: float = 400.0
@export var min_chase_speed: float = 200.0
@export var max_turn_speed: float = 25.0
@export var min_turn_speed: float = 15.0

@export var crash_vfx: GPUParticles2D
@export var crash_sfx: AudioStreamPlayer2D
@export var bleed_timer: Timer

var chase_speed: float = 300.0
var turn_speed: float = 20.0

func enter(_msg:={}) -> void:
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	
	enemy.sprite.hide()
	enemy.shadow.hide()
	
	crash_vfx.restart()
	crash_sfx.play()
	
	bleed_timer.start()

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


func _on_bleed_timer_timeout() -> void:
	enemy.bleeder.bleed(1, 1.0, 5)
