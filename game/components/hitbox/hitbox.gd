class_name Hitbox
extends Area2D

signal hit(hurtbox: Hurtbox)

@export var damage: int = 1
@export var trigger_invinc: bool = false
@export var damage_cooldown: float = 0.5
@export var knockback_strength: float = 32.0
@export var knockback_skew: Vector2 = Vector2.ZERO

@export var height_based: bool = true
@export var height: float = 0.0
@export var height_radius: float = 0.0

@export var status_effect: StatusEffector.EFFECTS
@export var status_effect_ticks: int = 0

var cool: bool = false

func can_damage() -> bool:
	return not cool

func cooldown() -> void:
	cool = true
	await get_tree().create_timer(damage_cooldown, false).timeout
	cool = false
