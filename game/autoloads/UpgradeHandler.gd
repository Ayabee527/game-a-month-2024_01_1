extends Node

signal equips_updated(new_equips: Array[RogueUpgrade])

var WEAPONS = {
	"STARTER": load("res://player/weapons/starter.tres"),
	"DUAL STARTER": load("res://player/weapons/dual_starter.tres")
}

enum UPGRADES {
	STARTER_WEAPON,
	DUAL_STARTER,
	SEEING_RED_I,
	SEEING_GREEN_I,
	SEEING_BLUE_I,
	SEEING_YELLOW_I,
}

var equips: Array[RogueUpgrade] = [
	load("res://player/upgrades/starter.tres")
]: set = set_equips

var player: Player

func set_equips(new_equips: Array[RogueUpgrade]) -> void:
	equips = new_equips
	equips_updated.emit(equips)

func give_player_weapons(new_weapons: Array[Weapon]) -> void:
	if player == null:
		return
	
	var given_weapons := player.get_weapons()
	given_weapons.append_array(new_weapons)
	player.set_weapons(given_weapons)

func remove_player_weapons(weapons: Array[Weapon]) -> void:
	var new_weapons := player.get_weapons()
	for weapon: Weapon in weapons:
		new_weapons.erase(weapon)
	player.set_weapons(new_weapons)

func upgrade_is_equipped(id: UPGRADES) -> bool:
	for upgrade: RogueUpgrade in equips:
		if upgrade.upgrade_id == id:
			return true
	
	return false

func activate_upgrade(id: UPGRADES) -> void:
	match id:
		UPGRADES.STARTER_WEAPON:
			give_player_weapons([WEAPONS["STARTER"]])
		UPGRADES.DUAL_STARTER:
			give_player_weapons([WEAPONS["DUAL STARTER"]])
		_:
			pass

func deactivate_upgrade(id: UPGRADES) -> void:
	match id:
		UPGRADES.STARTER_WEAPON:
			remove_player_weapons([WEAPONS["STARTER"]])
		UPGRADES.DUAL_STARTER:
			remove_player_weapons([WEAPONS["DUAL STARTER"]])
		_:
			pass
