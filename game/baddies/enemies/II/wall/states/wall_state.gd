class_name EnemyWallState
extends State

var enemy: EnemyWall

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyWall
	assert(enemy != null)
