extends Node2D

signal enemy_killed(enemy: Node2D)

const ENEMIES = {
	"KAMIKAZE": preload("res://baddies/enemies/kamikaze/kamikaze.tscn")
}

const COSTS = {
	"KAMIKAZE": 3
}

@export var player: Player

@export var active: bool = true
@export var time_before_start: float = 3.0
@export var starting_spawn_points: int = 3

@export var spawn_timer: Timer

var spawns: int = 0
var points_per: int = 1

var spawn_points: int = 3

func _ready() -> void:
	if not active:
		return
	
	spawn_points = starting_spawn_points
	
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

func _on_spawn_timer_timeout() -> void:
	spawn_wave()
	spawns += 1
	
	spawn_points += points_per
	
	if spawns % 10 * points_per == 0:
		points_per += 1
