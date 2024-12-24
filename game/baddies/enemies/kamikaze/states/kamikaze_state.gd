class_name EnemyKamikazeState
extends State

var enemy: EnemyKamikaze

func _ready() -> void:
	await owner.ready
	enemy = owner as EnemyKamikaze
	assert(enemy != null)
