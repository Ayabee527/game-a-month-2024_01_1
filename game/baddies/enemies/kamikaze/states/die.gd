extends EnemyKamikazeState

@export var fuse_time: float = 0.25
@export var explode_timer: Timer

func enter(msg:={}) -> void:
	enemy.health_indicator.kill()
	enemy.player_tracker.kill()
	
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.coll_shape.set_deferred("disabled", true)
	enemy.set_deferred("freeze", true)
	
	enemy.died.emit()
	
	if not msg.has("fuse"):
		explode()
		return
	
	enemy.sprite.squish(
		1.0, 4.0, true, true
	)
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		enemy.sprite, "global_scale", Vector2.ZERO, fuse_time
	)
	tween.play()
	
	explode_timer.start(fuse_time)

func physics_update(delta: float) -> void:
	pass

func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")

func explode() -> void:
	enemy.bleeder.bleed(enemy.health.max_health, 2.0)
	enemy.weapon_handler.shoot()
	enemy.sprite.hide()
	enemy.shadow.hide()
	await get_tree().create_timer(2.0, false).timeout
	enemy.queue_free()

func _on_explode_timer_timeout() -> void:
	explode()
