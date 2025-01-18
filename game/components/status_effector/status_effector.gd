class_name StatusEffector
extends Node2D

const MAX_TICKS: int = 30

signal effect_activated(effect: EFFECTS, ticks: int)
signal effects_ticked(effects: Array[EFFECTS])
signal effect_expired(effect: EFFECTS)

enum EFFECTS {
	BURN, # Damage over time
	POISON, # Damage over time that scales with ticks
	STUN, # Pauses enemy till expiration
	SHOCK, # Low ticks, damages on activation, releases lightning on expiration
	BLEED, # Take damage proportional to health lost
	VOLATILE, # Enemies explode on die while this is active
}

var cur_effects: Array[int] = [0, 0, 0, 0, 0, 0]

func tick_effects() -> void:
	for effect: int in cur_effects:
		if effect > 0:
			effect -= 1
			effect = clampi(effect, 0, MAX_TICKS)

func activate_effect(effect: EFFECTS, ticks: int) -> void:
	pass


func _on_tick_tocker_timeout() -> void:
	tick_effects()
