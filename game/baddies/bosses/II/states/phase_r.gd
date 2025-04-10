extends BossIIState

@export var max_shots: int = 20
@export var max_pull_force: float = 800.0
@export var min_pull_force: float = 300.0

@export var weapon: WeaponHandler
@export var tether_vfx: GPUParticles2D

var pull_force: float
var shots: int = 0

func enter(_msg:={}) -> void:
	shots = 0
	pull_force = min_pull_force
	boss.set_color(Color.RED)
	tether_vfx.emitting = true

func physics_update(delta: float) -> void:
	boss.player.apply_central_force(
		boss.player.global_position.direction_to(boss.global_position) * pull_force
	)

func exit() -> void:
	weapon.firing = false
	tether_vfx.emitting = false


func _on_tether_aura_fired() -> void:
	if not is_active:
		return
	
	boss.sprite.squish(
		0.5, 1.5, true, true
	)
	
	shots += 1
	pull_force = lerp(
		min_pull_force, max_pull_force, float(shots) / max_shots
	)
	
	if shots == max_shots:
		state_machine.transition_to("PhaseSwitch")


func _on_boss_ii_color_set(new_color: Color) -> void:
	if is_active:
		weapon.firing = true
