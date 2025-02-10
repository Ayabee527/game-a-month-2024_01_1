class_name EnemyBeybladeState
extends State

var enemy: EnemyBeyblade

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyBeyblade
	assert(enemy != null)
