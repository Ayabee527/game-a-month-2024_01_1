extends BossIIState

const SACRIFICE = preload("res://baddies/enemies/I/kamikaze/kamikaze.tscn")
const MINION = "put red minion here"

func enter(_msg:={}) -> void:
	boss.set_color(Color.RED)
