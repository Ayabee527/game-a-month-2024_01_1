extends EnemyMoleState

@export var max_chase_speed: float = 600.0
@export var min_chase_speed: float = 400.0
@export var max_turn_speed: float = 70.0
@export var min_turn_speed: float = 50.0

@export var peek_timer: Timer
@export var peek_sfx: AudioStreamPlayer2D

var chase_speed: float = 100.0
var turn_speed: float = 20.0

var peeks: int = 0

func enter(_msg:={}) -> void:
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	
	enemy.sprite.hide()
	enemy.shadow.hide()
	
	enemy.hurt_coll_shape.set_deferred("disabled", false)
	enemy.coll_shape.set_deferred("disabled", false)
	enemy.hit_coll_shape.set_deferred("disabled", true)
	
	peek_timer.start()
	
	peeks = 0

func physics_update(delta: float) -> void:
	var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
	enemy.global_transform = enemy.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	enemy.apply_central_force(
		Vector2.from_angle(enemy.global_rotation) * chase_speed
	)

func exit() -> void:
	peek_timer.stop()

func _on_peek_timer_timeout() -> void:
	enemy.sprite.visible = not enemy.sprite.visible
	enemy.shadow.visible = enemy.sprite.visible
	
	if enemy.sprite.visible:
		peeks += 1
		peek_sfx.play()
	
	if peeks >= 3 and is_active:
		state_machine.transition_to("Leap")
