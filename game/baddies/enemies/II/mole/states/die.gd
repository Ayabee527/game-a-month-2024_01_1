extends EnemyMoleState

@export var die_sfx: AudioStreamPlayer2D

var tween: Tween

func enter(_msg:={}) -> void:
	enemy.died.emit()
	enemy.health_indicator.kill()
	enemy.player_tracker.kill()
	enemy.coll_shape.set_deferred("disabled", true)
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.hit_coll_shape.set_deferred("disabled", true)
	enemy.set_deferred("freeze", true)
	die_sfx.play()
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		enemy, "warn_radius", 0, 0.5
	)
	
	enemy.bleeder.bleed(5, 2.0, 40)
	enemy.sprite.hide()
	enemy.shadow.hide()
	await get_tree().create_timer(2.0, false).timeout
	enemy.queue_free()

func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")
