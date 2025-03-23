extends BossIState

const MINIONS = [
	preload("res://baddies/enemies/I/dasher/dasher.tscn"),
	preload("res://baddies/enemies/I/kamikaze/kamikaze.tscn"),
	preload("res://baddies/enemies/I/thrower/thrower.tscn"),
	preload("res://baddies/enemies/I/hopper/hopper.tscn")
]

@export var min_summons: int = 2
@export var max_summons: int = 4

@export var summon_sfx: AudioStreamPlayer2D

func enter(_msg:={}) -> void:
	boss.set_color(Color.PURPLE)

func exit() -> void:
	MainCam.min_shake_stength = 0.0

func summon_minions() -> void:
	summon_sfx.play()
	var summon_count: int = randi_range(min_summons, max_summons)
	for i: int in summon_count:
		var enemy: Node2D = MINIONS.pick_random().instantiate()
		enemy.global_position = boss.player.global_position + (
			Vector2.from_angle(TAU * randf()) * 400.0
		)
		add_child(enemy)
		await get_tree().create_timer(0.5, false).timeout
	
	state_machine.transition_to("PhaseSwitch")


func _on_boss_i_color_set(new_color: Color) -> void:
	if is_active:
		MainCam.shake(25, 10.0, 2.0)
		MainCam.min_shake_stength = 5.0
		summon_minions()
