class_name EnemyThrowerState
extends State

var enemy: EnemyThrower

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyThrower
	assert(enemy != null)
