class_name BossIIState
extends State

var boss: BossII

func _ready() -> void:
	await owner.ready
	boss = owner as BossII
	assert(boss != null)
