extends Node2D

@export var player: Player

var player_dead: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if player_dead:
		if Input.is_action_just_pressed("retry"):
			restart()

func restart() -> void:
	reset_globals()
	SceneSwitcher.switch_to("res://main/main.tscn")

func reset_globals() -> void:
	RogueHandler.points = 1
	RogueHandler.damage_plus = 0
	RogueHandler.hurt_plus = 0
	
	for equip in UpgradeHandler.equips:
		UpgradeHandler.deactivate_upgrade(equip.upgrade_id)
	UpgradeHandler.equips.clear()
	UpgradeHandler.equips.append( load("res://player/upgrades/starter.tres") )
	UpgradeHandler.activate_upgrade(UpgradeHandler.UPGRADES.STARTER_WEAPON)
	UpgradeHandler.equips = UpgradeHandler.equips
	
	UpgradeHandler.payload_queue = []
	
	MainCam.zoom_factor = 1.0
	MainCam.min_shake_stength = 0.0


func _on_player_died() -> void:
	player_dead = true
