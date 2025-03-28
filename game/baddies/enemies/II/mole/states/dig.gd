extends EnemyMoleState

@export var max_chase_speed: float = 600.0
@export var min_chase_speed: float = 400.0
@export var max_turn_speed: float = 70.0
@export var min_turn_speed: float = 50.0

@export var crash_vfx: GPUParticles2D
@export var crash_sfx: AudioStreamPlayer2D
@export var crash_wpn: WeaponHandler
@export var bleed_timer: Timer
@export var patience_timer: Timer

var chase_speed: float = 500.0
var cur_chase_speed: float = 0.0
var turn_speed: float = 60.0

var tween: Tween
var tween2: Tween

func enter(_msg:={}) -> void:
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	
	cur_chase_speed = 0
	
	enemy.sprite.hide()
	enemy.shadow.hide()
	
	enemy.bleeder.bleed(2, 2.0, 40)
	crash_vfx.restart()
	crash_sfx.play()
	
	crash_wpn.shoot_all()
	
	bleed_timer.start()
	patience_timer.start()
	
	enemy.coll_shape.set_deferred("disabled", true)
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.hit_coll_shape.set_deferred("disabled", true)
	
	tween = create_tween()
	tween.tween_property(
		self, "cur_chase_speed", chase_speed, 1.0
	).from(0.0)
	
	tween2 = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween2.set_parallel()
	tween2.tween_property(
		enemy, "warn_alpha", 0.1, 0.5
	)
	tween2.tween_property(
		enemy, "warn_radius", 24, 0.5
	)

func physics_update(delta: float) -> void:
	var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
	enemy.global_transform = enemy.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	enemy.apply_central_force(
		Vector2.from_angle(enemy.global_rotation) * cur_chase_speed
	)

func exit() -> void:
	bleed_timer.stop()
	patience_timer.stop()
	tween.stop()
	tween2.stop()


func _on_bleed_timer_timeout() -> void:
	enemy.bleeder.bleed(1, 1.0, 5)


func _on_peek_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_active:
		state_machine.transition_to("Peek")


func _on_patience_timer_timeout() -> void:
	if is_active:
		state_machine.transition_to("Peek")
