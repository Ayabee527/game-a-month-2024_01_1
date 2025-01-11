class_name LaserData
extends AttackData

const attack = preload("res://components/weapon/attacks/laser/laser.tscn")

@export_group("Basics")
@export var width: float = 3.0
@export var sustain_time: float = 0.25
@export var fade_time: float = 0.25
@export var turn_speed: float = 0.0

@export_group("Tracking")
@export var homes: bool = false
@export var targets: Array[String] = ["player"]
@export var start_track_speed: float = 360.0
@export var end_track_speed: float = 360.0
@export var track_accel_time: float = 0.0
