extends EnemyMoleState

@export var max_chase_speed: float = 600.0
@export var min_chase_speed: float = 400.0
@export var max_turn_speed: float = 70.0
@export var min_turn_speed: float = 50.0

@export var crash_vfx: GPUParticles2D
@export var crash_sfx: AudioStreamPlayer2D
@export var crash_wpn: WeaponHandler
@export var leap_sfx: AudioStreamPlayer2D

var chase_speed: float = 100.0
var turn_speed: float = 20.0

var tween: Tween

func enter(_msg:={}) -> void:
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
	
	enemy.sprite.modulate.a = 1.0
	enemy.sprite.show()
	enemy.shadow.show()
	
	crash_vfx.restart()
	
	crash_sfx.play()
	enemy.bleeder.bleed(2, 2.0, 40)
	
	crash_wpn.shoot_all()
	
	enemy.coll_shape.set_deferred("disabled", true)
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.hit_coll_shape.set_deferred("disabled", true)
	
	enemy.sprite.squish(
		0.5, 4.0, true, true
	)
	enemy.sprite.jump(48.0, 0.6, 0.4)
	enemy.look_at(enemy.player.global_position)
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	#tween.tween_property(
		#enemy, "warn_radius", 24, 0.5
	#)
	#tween.tween_property(
		#enemy, "warn_alpha", 0.0, 0.5
	#)

func physics_update(delta: float) -> void:
	var new_transform = enemy.global_transform.looking_at(enemy.player.global_position)
	enemy.global_transform = enemy.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	enemy.apply_central_force(
		Vector2.from_angle(enemy.global_rotation) * chase_speed
	)

func exit() -> void:
	tween.stop()

func _on_height_sprite_ground_hit() -> void:
	if is_active:
		enemy.bleeder.bleed(2, 2.0, 40)
		state_machine.transition_to("Dig")
