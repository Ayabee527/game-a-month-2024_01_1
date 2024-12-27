class_name BossIState
extends State

var boss: BossI

func _ready() -> void:
	await owner.ready
	boss = owner as BossI
	assert(boss != null)
