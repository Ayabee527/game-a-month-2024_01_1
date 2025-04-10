class_name EnemyHandler
extends Node2D

signal wave_cleared(wave: int, size: int)
signal enemy_killed(enemy: Node2D)
signal boss_killed(boss: Node2D)

# PRE BOSS: MIN IS 3, MAX IS 21
# AFTER BOSS 1: MIN IS 39, MAX IS 45

const BOSSES = [
	preload("res://baddies/bosses/I/boss_I.tscn"),
	preload("res://baddies/bosses/II/boss_II.tscn")
]

const ENEMIES = {
	"SACRIFICE I": preload("res://baddies/enemies/I/kamikaze/kamikaze.tscn"),
	"MAGE I": preload("res://baddies/enemies/I/thrower/thrower.tscn"),
	"HOPPER I": preload("res://baddies/enemies/I/hopper/hopper.tscn"),
	"MELEE I": preload("res://baddies/enemies/I/dasher/dasher.tscn"),
	
	"MAGE II": preload("res://baddies/enemies/II/sniper/sniper.tscn"),
	"HOPPER II": preload("res://baddies/enemies/II/mole/mole.tscn"),
	"MELEE II": preload("res://baddies/enemies/II/darter/darter.tscn"),
	"SACRIFICE II": preload("res://baddies/enemies/II/tether/tether.tscn")
}

const COSTS = {
	"SACRIFICE I": 3,
	"MAGE I": 4,
	"HOPPER I": 4,
	"MELEE I": 4,
	
	"MAGE II": 11,
	"HOPPER II": 12,
	"MELEE II": 8,
	"SACRIFICE II": 8,
}

const TIER_I_COSTS = {
	"SACRIFICE I": 3,
	"MAGE I": 4,
	"HOPPER I": 4,
	"MELEE I": 4,
}

const TIER_II_COSTS = {
	"MAGE II": 11,
	"HOPPER II": 12,
	"MELEE II": 8,
	"SACRIFICE II": 8,
}

@export var player: Player

@export var tier_themes: Array[AudioStreamPlayer]

@export var starting_wave: int = 1
@export var starting_upgrades: Array[RogueUpgrade] = [preload("res://player/upgrades/starter.tres")]
@export var active: bool = true
@export var time_before_start: float = 3.0
@export var time_between_waves: float = 1.0
@export var starting_spawn_points: int = 3
@export var starting_points_per: int = 2

@export var spawn_timer: Timer
@export var multikill_timer: Timer
@export var world: Node2D
@export var shop_menu: ShopMenu

var spawns: int = 0
var enemy_kills: int = 0
var bosses_killed: int = 0
var points_per: int = 2

var spawn_points: int = 3

var boss_alive: bool = true

var wave_size: int = 0
var wave_kills: int = 0
var current_wave: Array[Node2D] = []

var multikills: int = 0

var music: AudioStreamPlayer

func _ready() -> void:
	if not active:
		return
	
	spawns = starting_wave - 1
	
	spawn_points = starting_spawn_points
	if starting_wave != 1:
		points_per = ( roundi(
			(2 * log(spawns)) + ( (0.01 * spawns) * sin(spawns) )
		) * (bosses_killed + 1) * 3 ) + starting_points_per
		spawn_points += points_per
	
	bosses_killed = floor(spawns / 15.0)
	for i: int in bosses_killed:
		shop_menu.upgrade_tier_silent()
	
	cheat_upgrades()
	
	music = tier_themes[bosses_killed]
	music.play()
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		music, "pitch_scale", 1.0, 2.0
	).from(0.01)
	
	await get_tree().create_timer(time_before_start, false).timeout
	wave_cleared.emit(spawns, 0)
	if (spawns + 1) % 15 == 0:
		spawn_boss()
	else:
		spawn_wave()
	#spawn_timer.start()

func cheat_upgrades() -> void:
	for equip: RogueUpgrade in UpgradeHandler.equips:
		UpgradeHandler.deactivate_upgrade(equip.upgrade_id)
	UpgradeHandler.equips.clear()
	
	for equip: RogueUpgrade in starting_upgrades:
		UpgradeHandler.equips.append(equip)
		UpgradeHandler.activate_upgrade(equip.upgrade_id)
	UpgradeHandler.equips = UpgradeHandler.equips

func spawn_wave() -> void:
	var chosens: Array = []
	#var enemies: Array = COSTS.keys().duplicate()
	var enemies: Array = []
	
	var points_out: bool = false
	while spawn_points > 0:
		enemies.clear()
		var tier_i := TIER_I_COSTS.keys().duplicate()
		tier_i.shuffle()
		enemies.append_array(tier_i)
		if bosses_killed > 0:
			var tier_ii := TIER_II_COSTS.keys().duplicate()
			tier_ii.shuffle()
			enemies.append_array(tier_ii)
		
		print(enemies)
		
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
	
	wave_size = chosens.size()
	wave_kills = 0
	
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
		current_wave.append(enemy)
		await get_tree().create_timer(0.1, false).timeout

func kill_enemy(enemy: Node2D) -> void:
	if player.dead:
		return
	
	enemy_killed.emit(enemy)
	spawn_points += 1
	enemy_kills += 1
	wave_kills += 1
	
	multikills += 1
	multikill_timer.start()
	
	current_wave.erase(enemy)
	if wave_kills >= wave_size:
		spawns += 1
		wave_cleared.emit(spawns, wave_size)
		
		points_per = ( roundi(
			(2 * log(spawns)) + ( (0.01 * spawns) * sin(spawns) )
		) * (bosses_killed + 1) * 3 ) + starting_points_per
		spawn_points += points_per
		
		prints(spawns, spawn_points)
		
		await get_tree().create_timer(time_between_waves, false).timeout
		if (spawns + 1) % 15 == 0:
			spawn_boss()
		else:
			if (spawns + 1) % 5 == 0:
				player.toggle_invinc(true)
				shop_menu.open()
			else:
				spawn_wave()

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
	if player.dead:
		return
	
	boss_killed.emit(boss)
	bosses_killed += 1
	boss_alive = false
	spawns += 1
	
	wave_cleared.emit(spawns, 1)
	
	shop_menu.new_tier_waiting = true
	player.toggle_invinc(true)
	shop_menu.open()
	
	music = tier_themes[bosses_killed]
	
	#music.stream_paused = false
	#var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(
		#music, "pitch_scale", 1.0, 1.0
	#).from(0.01)

func _on_spawn_timer_timeout() -> void:
	return
	#
	#spawn_wave()
	#spawns += 1
	#
	#spawn_points += points_per
	#
	#points_per = roundi(
		#log(spawns) + ( (0.005 * spawns) * sin(spawns) )
	#) + starting_points_per
	#
	#if spawns % 25 == 0:
		#spawn_boss()


func _on_shop_menu_confirmed() -> void:
	if player.dead:
		return
	
	player.toggle_invinc(false)
	spawn_wave()


func _on_multi_kill_timer_timeout() -> void:
	if multikills < 1:
		return
	
	var kill_text: String = ""
	match multikills:
		1:
			kill_text = "[shake]KILL!"
		2:
			kill_text = "[shake]DOUBLE KILL!!"
		3:
			kill_text = "[shake]TRIPLE KILL!!!"
		4:
			kill_text = "[shake]QUADRUPLE KILL!!!!"
		_:
			kill_text = "[shake]MULTIKILL [color=red]x" + str(multikills) + "[/color]!!!!!"
	
	RogueHandler.trigger_style(
		player.global_position, kill_text, snappedi( floori( 10 * (bosses_killed + 1) * multikills * pow(1.1, multikills) ), 5 )
	)
	
	multikills = 0


func _on_player_died() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		music, "pitch_scale", 0.7, 2.0
	)
