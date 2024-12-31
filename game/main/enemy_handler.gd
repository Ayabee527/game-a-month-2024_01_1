extends Node2D

signal enemy_killed(enemy: Node2D)
signal boss_killed(boss: Node2D)

const BOSSES = [
	preload("res://baddies/bosses/I/boss_I.tscn")
]

const ENEMIES = {
	"SACRIFICE I": preload("res://baddies/enemies/I/kamikaze/kamikaze.tscn"),
	"MAGE I": preload("res://baddies/enemies/I/thrower/thrower.tscn"),
	"HOPPER I": preload("res://baddies/enemies/I/turret/hopper.tscn"),
	"MELEE I": preload("res://baddies/enemies/I/dasher/dasher.tscn")
}

const COSTS = {
	"SACRIFICE I": 3,
	"MAGE I": 4,
	"HOPPER I": 4,
	"MELEE I": 4
}

@export var player: Player

@export var active: bool = true
@export var time_before_start: float = 3.0
@export var starting_spawn_points: int = 3
@export var starting_points_per: int = 2

@export var spawn_timer: Timer
@export var music: AudioStreamPlayer
@export var world: Node2D

var spawns: int = 0
var enemy_kills: int = 0
var bosses_killed: int = 0
var points_per: int = 2

var spawn_points: int = 3

var boss_alive: bool = true

func _ready() -> void:
	if not active:
		return
	
	spawn_points = starting_spawn_points
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		music, "pitch_scale", 1.0, 2.0
	).from(0.01)
	
	await get_tree().create_timer(time_before_start, false).timeout
	spawn_wave()
	spawn_timer.start()

func spawn_wave() -> void:
	var chosens: Array = []
	var enemies: Array = COSTS.keys().duplicate()
	
	var points_out: bool = false
	while spawn_points > 0:
		enemies = COSTS.keys().duplicate()
		
		enemies.shuffle()
		var chosen_enemy = enemies.pop_back()
		
		while (COSTS[chosen_enemy] > spawn_points):
			if enemies.size() == 0:
				points_out = true
				break
			
			chosen_enemy = enemies.pop_back()
		
		if points_out:
			break
		
		spawn_points -= COSTS[chosen_enemy]
		
		chosens.append(chosen_enemy)
	
	for name: String in chosens:
		var enemy: Node2D = ENEMIES[name].instantiate()
		#enemy.global_position = (
			#Vector2.ONE * 128.0
			#+ Vector2.from_angle(TAU * randf()) * 256.0
		#)
		enemy.global_position = player.global_position + (
			Vector2.from_angle(TAU * randf()) * 400.0
		)
		if enemy.has_signal("died"):
			enemy.died.connect(kill_enemy.bind(enemy))
		else:
			enemy.tree_exiting.connect(kill_enemy.bind(enemy))
		add_child(enemy)

func kill_enemy(enemy: Node2D) -> void:
	enemy_killed.emit(enemy)
	spawn_points += 1
	enemy_kills += 1

func spawn_boss() -> void:
	var boss: Node2D = BOSSES[bosses_killed].instantiate()
	boss.global_position = player.global_position + (
		Vector2.from_angle(TAU * randf()) * 400.0
	)
	if boss.has_signal("died"):
		boss.died.connect(kill_boss.bind(boss))
	else:
		boss.tree_exiting.connect(kill_boss.bind(boss))
	add_child(boss)
	boss_alive = true
	spawn_timer.stop()
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		music, "pitch_scale", 0.01, 1.0
	).from(1.0)
	await tween.finished
	music.stream_paused = true

func kill_boss(boss: Node2D) -> void:
	boss_killed.emit(boss)
	bosses_killed += 1
	boss_alive = false
	spawn_timer.start()
	
	music.stream_paused = false
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		music, "pitch_scale", 1.0, 1.0
	).from(0.01)

func _on_spawn_timer_timeout() -> void:
	spawn_wave()
	spawns += 1
	
	spawn_points += points_per
	
	points_per = roundi(
		log(0.5 * spawns) + ( (0.005 * spawns) * sin(spawns) )
	) + starting_points_per
	
	if spawns % 25 == 0:
		spawn_boss()
