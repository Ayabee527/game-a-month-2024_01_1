class_name EnemyDarterState
extends State

var enemy: EnemyDarter

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyDarter
	assert(enemy != null)
