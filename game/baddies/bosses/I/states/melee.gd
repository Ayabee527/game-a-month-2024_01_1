extends BossIState

@export var warn_time: float = 0.75
@export var max_dashes: int = 5

@export var dash_speed: float = 1200
@export var turn_speed: float = 20.0

@export var dash_timer: Timer
@export var dash_sfx: AudioStreamPlayer2D

var color: Color
var dashes: int = 0

func enter(_msg:={}) -> void:
	dashes = 0
	boss.set_color(Color.YELLOW)

func physics_update(delta: float) -> void:
	if boss.hit_coll_shape.disabled:
		var new_transform = boss.global_transform.looking_at(boss.player.global_position)
		boss.global_transform = boss.global_transform.interpolate_with(
			new_transform, turn_speed * delta
		)
	
	if boss.linear_velocity.length() < 128.0 and not boss.hit_coll_shape.disabled:
		boss.hit_coll_shape.set_deferred("disabled", true)

func exit() -> void:
	boss.hit_coll_shape.set_deferred("disabled", true)

func dash() -> void:
	#boss.sprite.modulate = Color.WHITE
	boss.sprite.squish(
		warn_time, 1.5, true, true
	)
	
	await get_tree().create_timer(warn_time, false).timeout
	
	#dash_boom.shoot()
	dash_sfx.play()
	boss.linear_velocity = Vector2.ZERO
	boss.sprite.squish(
		warn_time, 1.5, true, false
	)
	#boss.sprite.modulate = color
	boss.hit_coll_shape.set_deferred("disabled", false)
	boss.apply_central_impulse(
		Vector2.from_angle(boss.global_rotation) * dash_speed
	)
	dashes += 1


func _on_dash_timer_timeout() -> void:
	if is_active:
		if dashes < max_dashes:
			dash()
		else:
			state_machine.transition_to("PhaseSwitch")

func _on_boss_i_color_set(new_color: Color) -> void:
	if is_active:
		color = new_color
		dash_timer.start()
		dash()
