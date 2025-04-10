extends BossIIState

@export var megablast: WeaponHandler
@export var spam: WeaponHandler
@export var snipe_timer: Timer

@export var turn_speed: float = 2.0

func enter(_msg:={}) -> void:
	boss.set_color(Color.GREEN)

func physics_update(delta: float) -> void:
	var new_transform = boss.global_transform.looking_at(boss.player.global_position)
	boss.global_transform = boss.global_transform.interpolate_with(
		new_transform, turn_speed * delta
	)

func exit() -> void:
	spam.firing = false


func _on_boss_ii_color_set(new_color: Color) -> void:
	if is_active:
		megablast.shoot()
		spam.firing = true
		snipe_timer.start()

# TODO: CHANGE MEGABLAST TO SNIPES LIKE SNIPER ENEMY AND
# HAVE SPAM IN BURSTS IN BETWEEN SNIPES

func _on_snipe_timer_timeout() -> void:
	if is_active:
		state_machine.transition_to("PhaseSwitch")
