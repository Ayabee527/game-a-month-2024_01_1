extends EnemyThrowerState

@export var die_burst: WeaponHandler

func enter(_msg:={}) -> void:
	enemy.health_indicator.kill()
	enemy.player_tracker.kill()
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.set_deferred("freeze", true)
	
	enemy.bleeder.bleed(enemy.health.max_health, 2.0, 40)
	enemy.pointer.bleed(enemy.health.max_health)
	die_burst.shoot()
	enemy.sprite.hide()
	enemy.shadow.hide()
	await get_tree().create_timer(2.0, false).timeout
	enemy.queue_free()

func _on_health_has_died() -> void:
	if not is_active:
		state_machine.transition_to("Die")
