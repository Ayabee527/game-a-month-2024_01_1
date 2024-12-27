class_name EnemyDasherState
extends State

var enemy: EnemyDasher

func _ready() -> void:
	await owner.ready
	enemy  = owner as EnemyDasher
	assert(enemy != null)
