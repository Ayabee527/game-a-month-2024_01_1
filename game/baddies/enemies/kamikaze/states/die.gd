extends EnemyKamikazeState

@export var anim_player: AnimationPlayer

func enter(_msg:={}) -> void:
	Util.squish(
		enemy.sprite, 1.0, 4.0, true, true
	)
	enemy.health_indicator.kill()
	enemy.player_tracker.kill()
	
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.coll_shape.set_deferred("disabled", true)
	
	enemy.died.emit()
	anim_player.play("explode")

func physics_update(delta: float) -> void:
	pass

func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"explode":
			enemy.bleeder.bleed(enemy.health.max_health, 2.0)
			enemy.weapon_handler.shoot()
			enemy.sprite.hide()
			await get_tree().create_timer(2.0, false).timeout
			enemy.queue_free()
