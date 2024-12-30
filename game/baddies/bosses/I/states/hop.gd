extends BossIState

@export var max_hops: int = 5

@export var time_to_peak: float = 0.5
@export var time_to_fall: float = 0.4

@export var turn_speed: float = 10.0

@export var hop_boom: WeaponHandler

var hops: int = 0

func enter(_msg:={}) -> void:
	hops = 0
	boss.set_color(Color.BLUE)

func physics_update(delta: float) -> void:
	var new_transform = boss.global_transform.looking_at(boss.player.global_position)
	boss.global_transform = boss.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)

func exit() -> void:
	boss.linear_damp = 2.5
	boss.linear_velocity = Vector2.ZERO
	hop_boom.firing = false

func hop() -> void:
	boss.sprite.squish(
		0.5, 4.0, true, true
	)
	var total_time: float = time_to_peak + time_to_fall
	#var jump_distance: float = randf_range(min_leap_distance, max_leap_distance)
	var jump_distance: float = boss.global_position.distance_to(
		boss.player.global_position + boss.player.linear_velocity
	) / 2.0
	
	var jump_velocity: float = jump_distance / ( 0.5 * total_time )
	
	boss.sprite.jump(48.0, time_to_peak, time_to_fall)
	boss.linear_damp = 0.0
	boss.linear_velocity = Vector2.ZERO
	boss.apply_central_impulse( Vector2.from_angle(boss.global_rotation) * jump_velocity )
	hops += 1


func _on_height_sprite_ground_hit() -> void:
	if is_active:
		hop_boom.shoot()
		if hops < max_hops:
			MainCam.shake(10.0, 10.0, 2.0)
			boss.bleeder.bleed(3, 2.0, 50)
			hop()
		else:
			state_machine.transition_to("PhaseSwitch")


func _on_boss_i_color_set(new_color: Color) -> void:
	if is_active:
		hop()
