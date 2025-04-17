extends BossIIState

const LINE_WARNING := preload("res://components/line_warning/line_warning.tscn")

@export var max_dashes: int = 5
@export var dash_speed: float = 700.0
@export var vibe_speed: float = 700.0
@export var turn_speed: float = 3.0
@export var predict_speed: float = 3.0

@export var dash_timer: Timer
@export var steering: Marker2D

var vibing: bool = false
var dashes: int = 0

func enter(_msg:={}) -> void:
	dashes = 0
	vibing = false
	boss.set_color(Color.YELLOW, Color.TRANSPARENT)

func physics_update(delta: float) -> void:
	if vibing:
		var new_transform = boss.global_transform.looking_at(
			boss.player.global_position
			+ (boss.player.linear_velocity * (
				dash_speed / boss.global_position.distance_to(boss.player.global_position)
			))
		)
		boss.global_transform = boss.global_transform.interpolate_with(
			new_transform, predict_speed * delta
		)
		
		var steering_transform = steering.global_transform.looking_at(boss.player.global_position)
		steering.global_transform = steering.global_transform.interpolate_with(
			steering_transform, turn_speed * delta
		)
		
		boss.apply_central_force(
			Vector2.from_angle(steering.global_rotation) * vibe_speed
		)

func exit() -> void:
	boss.linear_damp = 2

func vibe() -> void:
	boss.hit_coll_shape.set_deferred("disabled", true)
	boss.linear_damp = 2
	vibing = true
	var warn := LINE_WARNING.instantiate()
	warn.color = Color.YELLOW
	warn.width = 32.0
	warn.warn_time = 1.0
	boss.add_child(warn)
	await warn.fired
	dash()

func dash() -> void:
	dashes += 1
	
	boss.linear_damp = 0.7
	boss.sprite.squish(0.5, 3.0, false, true)
	boss.hit_coll_shape.set_deferred("disabled", false)
	boss.apply_central_impulse(
		Vector2.from_angle(boss.global_rotation) * dash_speed
	)
	dash_timer.start()
	vibing = false

func _on_boss_ii_color_set(_new_color_1: Color, _new_color_2: Color) -> void:
	if is_active:
		vibe()


func _on_dash_timer_timeout() -> void:
	if is_active:
		if dashes >= max_dashes:
			state_machine.transition_to("PhaseSwitch")
			return
		vibe()
