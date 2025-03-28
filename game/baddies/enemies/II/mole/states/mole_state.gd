class_name EnemyMoleState
extends State

var enemy: EnemyMole

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyMole
	assert(enemy != null)
