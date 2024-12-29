extends BossIState

@export var max_shots: int = 30
@export var chase_speed: float = 600.0
@export var turn_speed: float = 15.0

@export var sacri_target: Marker2D
@export var rain: WeaponHandler

var shots: int = 0

func enter(_msg:={}) -> void:
	shots = 0
	boss.set_color(Color.RED)
	sacri_target.global_position = boss.player.global_position
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		sacri_target, "modulate:a", 1.0, 1.0
	).from(0.0)

func physics_update(delta: float) -> void:
	var new_transform = sacri_target.global_transform.looking_at(
		boss.player.global_position + boss.player.linear_velocity
	)
	sacri_target.global_transform = sacri_target.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	sacri_target.global_position += Vector2.from_angle(
		sacri_target.global_rotation
	) * chase_speed * delta

func exit() -> void:
	rain.firing = false
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		sacri_target, "modulate:a", 0.0, 1.0
	)

func _on_boss_i_color_set(new_color: Color) -> void:
	if is_active:
		rain.firing = true


func _on_rain_fired() -> void:
	if is_active:
		if shots < max_shots:
			shots += 1
		else:
			state_machine.transition_to("PhaseSwitch")
