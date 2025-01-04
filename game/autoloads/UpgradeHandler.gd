extends Node

signal equips_updated(new_equips: Array[RogueUpgrade])

enum UPGRADES {
	STARTER_WEAPON,
	BLOOD_RED
}

var equips: Array[RogueUpgrade] = []: set = set_equips

func set_equips(new_equips: Array[RogueUpgrade]) -> void:
	equips = new_equips
	equips_updated.emit(equips)
