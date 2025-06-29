extends BossIIState

@export var max_snipes: int = 10

@export var max_chase_speed: float = 600.0
@export var min_chase_speed: float = 400.0
@export var max_steer_speed: float = 4.0
@export var min_steer_speed: float = 1.0

@export var sniper: WeaponHandler
@export var snipe_warning: LaserWarning
#@export var snipe_timer: Timer

@export var steering: Marker2D

@export var turn_speed: float = 4.0

var snipes: int = 0
var steer_speed: float = 3
var chase_speed: float = 300.0

func enter(_msg:={}) -> void:
	snipes = 0
	boss.set_color(Color.GREEN)
	
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	steer_speed = randf_range(min_steer_speed, max_steer_speed)

func physics_update(delta: float) -> void:
	var target_pos: Vector2 = (
		boss.player.global_position
		+ boss.player.linear_velocity
	)
	
	var new_transform = boss.global_transform.looking_at(target_pos)
	boss.global_transform = boss.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	var new_steer_transform = steering.global_transform.looking_at(boss.player.global_position)
	steering.global_transform = steering.global_transform.interpolate_with(
		new_steer_transform, turn_speed * delta
	)
	
	if boss.global_position.distance_to(
		boss.player.global_position
	) > 256.0:
		boss.apply_central_force(
			Vector2.from_angle(steering.global_rotation) * chase_speed
		)

func exit() -> void:
	#sniper.firing = false
	snipe_warning.active = false


func _on_boss_ii_color_set(_new_color: Color) -> void:
	if is_active:
		#sniper.firing = true
		snipe_warning.active = true


func _on_snipe_warning_fired() -> void:
	sniper.shoot_all()


func _on_sniper_fired() -> void:
	if is_active:
		snipes += 1
		if snipes >= max_snipes:
			state_machine.transition_to("PhaseSwitch")
