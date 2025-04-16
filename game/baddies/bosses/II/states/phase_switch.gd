extends BossIIState

#const PHASES_1: Array[String] = ["R", "G", "B", "Y"]
const PHASES_1: Array[String] = ["R", "G", "B", "Y"]
const PHASES_2: Array[String] = ["RG", "RB", "RY", "GB", "GY", "BY"]

var cycle: Array[String] = []

func enter(_msg:={}) -> void:
	if cycle.is_empty():
		if boss.phase == 0:
			cycle = PHASES_1.duplicate()
		else:
			cycle = PHASES_2.duplicate()
		cycle.shuffle()
	
	var next_state = cycle.pop_back()
	if boss.health.health > 0:
		state_machine.transition_to(next_state)
	else:
		state_machine.transition_to("Die")
