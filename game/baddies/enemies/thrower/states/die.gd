extends EnemyThrowerState

@export var die_burst: WeaponHandler

func enter(_msg:={}) -> void:
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	
	enemy.bleeder.bleed(enemy.health.max_health, 2.0)
	die_burst.shoot()
	enemy.hide()
	await get_tree().create_timer(2.0, false).timeout
	enemy.queue_free()

func _on_health_has_died() -> void:
	if not is_active:
		enemy.health_indicator.kill()
		state_machine.transition_to("Die")
