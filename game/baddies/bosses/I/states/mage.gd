extends BossIState

@export var max_shots: int = 10

@export var turn_speed: float = 10.0
@export var chase_speed: float = 1000.0

@export var mage_shot: WeaponHandler

var shots: int = 0

func enter(_msg:={}) -> void:
	shots = 0
	boss.set_color(Color.GREEN)

func physics_update(delta: float) -> void:
	var new_transform = boss.global_transform.looking_at(boss.player.global_position)
	boss.global_transform = boss.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	boss.apply_central_force(
		Vector2.from_angle(boss.global_rotation) * chase_speed
	)

func exit() -> void:
	mage_shot.firing = false

func _on_boss_i_color_set(new_color: Color) -> void:
	if is_active:
		mage_shot.firing = true


func _on_mage_shot_fired() -> void:
	if is_active:
		if shots < max_shots:
			shots += 1
		else:
			state_machine.transition_to("PhaseSwitch")
