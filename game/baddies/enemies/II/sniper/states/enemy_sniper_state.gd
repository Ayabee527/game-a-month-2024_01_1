class_name EnemySniperState
extends State

var enemy: EnemySniper

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemySniper
	assert(enemy != null)
