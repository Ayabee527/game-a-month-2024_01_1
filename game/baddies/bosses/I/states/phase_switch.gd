extends BossIState

const PHASES: Array[String] = ["Melee", "Hop", "Sacrifice", "Mage", "Summon"]

var cycle: Array[String] = []

func enter(_msg:={}) -> void:
	if cycle.is_empty():
		cycle = PHASES.duplicate()
		cycle.shuffle()
	
	var next_state = cycle.pop_back()
	if boss.health.health > 0:
		state_machine.transition_to(next_state)
	else:
		state_machine.transition_to("Die")
