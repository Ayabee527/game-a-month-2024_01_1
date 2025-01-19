class_name StatusEffector
extends Node2D

const MAX_TICKS: int = 30

signal effect_activated(effect: EFFECTS, ticks: int)
signal effects_ticked(effects: Array[EFFECTS])
signal effect_expired(effect: EFFECTS)

enum EFFECTS {
	BURN, # Damage over time
	POISON, # Damage over time that scales with ticks
	BLEED, # Take damage proportional to health lost
	VOLATILE, # High tick count, enemies explode on expiration
}

@export_group("Outer Dependencies")
@export var health: Health
@export_group("Inner Dependencies")
@export var volatility: WeaponHandler

var cur_effects: Array[int] = [0, 0, 0, 0]

func tick_effects() -> void:
	for i: int in cur_effects.size():
		var effect: int = cur_effects[i]
		if effect > 0:
			effect -= 1
			effect = clampi(effect, 0, MAX_TICKS)
			if effect == 0:
				effect_expired.emit(i)
				
				match i:
					EFFECTS.VOLATILE:
						volatility.shoot()

func activate_effect(effect: EFFECTS, ticks: int) -> void:
	if ticks > 0:
		cur_effects[effect] = clampi(ticks, 0, MAX_TICKS)
		effect_activated.emit(effect, cur_effects[effect])


func _on_tick_tocker_timeout() -> void:
	tick_effects()
