extends BossIIState

@export var max_shots: int = 20
@export var max_pull_force: float = 1000.0
@export var min_pull_force: float = 400.0

@export var max_chase_speed: float = 400.0
@export var min_chase_speed: float = 200.0
@export var max_turn_speed: float = 4.0
@export var min_turn_speed: float = 1.0

@export var tether_wpn: WeaponHandler
@export var laser_wpn: WeaponHandler
@export var tether_vfx: GPUParticles2D

var pull_force: float
var shots: int = 0

var chase_speed: float = 300.0
var turn_speed: float = 3.0

func enter(_msg:={}) -> void:
	shots = 0
	pull_force = min_pull_force
	boss.set_color(Color.RED, Color.GREEN)
	tether_vfx.emitting = true
	
	chase_speed = randf_range(min_chase_speed, max_chase_speed)
	turn_speed = randf_range(min_turn_speed, max_turn_speed)
