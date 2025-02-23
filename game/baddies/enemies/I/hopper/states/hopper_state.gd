class_name EnemyHopperState
extends State

var enemy: EnemyHopper

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyHopper
	assert(enemy != null)
