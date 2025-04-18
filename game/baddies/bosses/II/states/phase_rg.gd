extends BossIIState

@export var max_shots: int = 20
@export var max_pull_force: float = 900.0
@export var min_pull_force: float = 400.0

@export var max_chase_speed: float = 400.0
@export var min_chase_speed: float = 200.0
@export var max_turn_speed: float = 4.0
@export var min_turn_speed: float = 1.0

@export var tether_wpn: WeaponHandler
@export var spam_wpn: WeaponHandler
@export var tether_vfx: GPUParticles2D

var pull_force: float
var shots: int = 0

var chase_speed: float = 300.0
var turn_speed: float = 3.0

func enter(_msg:={}) -> void:
	shots = 0
	pull_force = min_pull_force
	spam_wpn.global_rotation = 0
	boss.set_color(Color.GREEN, Color.RED)
	tether_vfx.emitting = true
	
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)

func physics_update(delta: float) -> void:
	#boss.player.apply_central_force(
		#boss.player.global_position.direction_to(boss.global_position)
		#* pull_force
	#)
	
	#if boss.global_position.distance_to(boss.player.global_position) > 256.0:
	var new_transform = boss.global_transform.looking_at(boss.player.global_position)
	boss.global_transform = boss.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)
	
	boss.apply_central_force(
		Vector2.from_angle(boss.global_rotation) * chase_speed
	)

func exit() -> void:
	tether_wpn.firing = false
	spam_wpn.firing = false

func _on_tether_aura_2_fired() -> void:
	if not is_active:
		return
	
	tether_wpn.global_rotation = TAU * randf()
	
	shots += 1
	pull_force = lerp(
		min_pull_force, max_pull_force, float(shots) / max_shots
	)
	
	if shots == max_shots:
		state_machine.transition_to("PhaseSwitch")


func _on_boss_ii_color_set(_new_color_1: Color, _new_color_2: Color) -> void:
	if is_active:
		tether_wpn.firing = true
		spam_wpn.firing = true
