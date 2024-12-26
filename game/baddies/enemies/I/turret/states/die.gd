extends EnemyHopperState

@export var die_sfx: AudioStreamPlayer2D

func enter(_msg:={}) -> void:
	enemy.health_indicator.kill()
	enemy.player_tracker.kill()
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.set_deferred("freeze", true)
	die_sfx.play()
	
	enemy.bleeder.bleed(5, 2.0, 20)
	enemy.sprite.hide()
	enemy.shadow.hide()
	await get_tree().create_timer(2.0, false).timeout
	enemy.queue_free()

func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")
