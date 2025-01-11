class_name ExplosionData
extends AttackData

const attack = preload("res://components/weapon/attacks/explosion/explosion.tscn")

@export_group("Basics")
@export var radius: float = 32.0
@export var sides: int = 16
@export var expand_time: float = 0.25
@export var sustain_time: float = 0.25
@export var fade_time: float = 0.3
