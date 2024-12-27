extends BossIState

const PHASES: Array[String] = ["Melee", "Hop", "Sacrifice", "Mage", "Summon"]

var cycle: Array[String] = []

func enter(_msg:={}) -> void:
	if cycle.is_empty():
		cycle = PHASES.duplicate()
		cycle.shuffle()
	
	var next_state = cycle.pop_back()
	state_machine.transition_to(next_state)
