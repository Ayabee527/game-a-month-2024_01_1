extends BossIIState

const CIRCLE_WARNING := preload("res://components/circle_warning/circle_warning.tscn")

@export var max_leaps: int = 3

@export var max_chase_speed: float = 600.0
@export var min_chase_speed: float = 400.0
@export var max_turn_speed: float = 70.0
@export var min_turn_speed: float = 50.0

@export var dig_timer: Timer
@export var dig_vfx: GPUParticles2D
@export var crash_wpn: WeaponHandler

var leaps: int = 0

var chase_speed: float = 300.0
var turn_speed: float = 3.0

func enter(_msg:={}) -> void:
	leaps = 0
	boss.set_color(Color.BLUE)
	
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)

func physics_update(delta: float) -> void:
	if boss.sprite.height <= 0:
		var new_transform = boss.global_transform.looking_at(boss.player.global_position)
		boss.global_transform = boss.global_transform.interpolate_with(
			new_transform, turn_speed * delta
		)
		
		if not dig_timer.is_stopped():
			boss.apply_central_force(
				Vector2.from_angle(boss.global_rotation) * chase_speed
			)
		else:
			boss.apply_central_force(
				Vector2.from_angle(boss.global_rotation) * (chase_speed / 2.0)
			)

func exit() -> void:
	boss.sprite.show()
	boss.shadow.show()
	dig_vfx.emitting = false
	boss.hurt_coll_shape.set_deferred("disabled", false)

func peek() -> void:
	boss.hurt_coll_shape.set_deferred("disabled", false)
	
	if leaps >= max_leaps:
		state_machine.transition_to("PhaseSwitch")
		return
	
	var peeks: int = 3
	var warning := CIRCLE_WARNING.instantiate()
	#warning.global_position = boss.global_position
	warning.warn_time = 0.2 * (peeks * 2)
	warning.radius = 96
	warning.color = Color.BLUE
	boss.add_child(warning)
	
	for i: int in range(peeks * 2):
		if i % 2 == 0:
			boss.sprite.show()
			boss.shadow.show()
		else:
			boss.sprite.hide()
			boss.shadow.hide()
		await get_tree().create_timer(0.2, false).timeout
	leap()

func leap() -> void:
	leaps += 1
	
	boss.sprite.show()
	boss.shadow.show()
	crash_wpn.shoot()
	MainCam.shake(17, 7, 7)
	
	var peak_time: float = 0.6
	var fall_time: float = 0.4
	
	var jump_distance := boss.global_position.distance_to(
		boss.player.global_position
		+ ( boss.player.linear_velocity * (peak_time + fall_time) )
	)
	jump_distance = minf(jump_distance, 384.0)
	var jump_velocity := jump_distance / (peak_time + fall_time)
	
	boss.sprite.squish(
		0.5, 4.0, true, true
	)
	boss.linear_damp = 0
	boss.linear_velocity *= 0.0
	boss.sprite.jump(48.0, peak_time, fall_time)
	boss.apply_central_impulse(
		Vector2.from_angle(boss.global_rotation) * jump_velocity
	)
	warn(jump_velocity)

func warn(speed: float) -> void:
	var total_time: float = 1.0
	var jump_vector: Vector2 = Vector2.from_angle(boss.global_rotation) * speed * total_time
	
	var warning := CIRCLE_WARNING.instantiate()
	warning.global_position = boss.global_position + jump_vector
	warning.warn_time = total_time + 0.3
	warning.radius = 96
	warning.color = Color.BLUE
	boss.get_parent().add_child(warning)

func _on_boss_ii_color_set(new_color: Color) -> void:
	if is_active:
		peek()


func _on_height_sprite_ground_hit() -> void:
	if is_active:
		boss.bleeder.bleed(2, 2.0, 40)
		boss.sprite.hide()
		boss.shadow.hide()
		crash_wpn.shoot()
		dig_timer.start()
		dig_vfx.emitting = true
		boss.linear_velocity *= 0.0
		boss.linear_damp = 2
		boss.hurt_coll_shape.set_deferred("disabled", true)


func _on_dig_timer_timeout() -> void:
	dig_vfx.emitting = false
	peek()
