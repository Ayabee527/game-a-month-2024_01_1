extends EnemyKamikazeState

@export var fuse_time: float = 0.75
@export var die_timer: Timer

var shake_amount: float = 0.0

func enter(_msg:={}) -> void:
	enemy.hurt_coll_shape.set_deferred("disabled", true)
	enemy.coll_shape.set_deferred("disabled", true)
	
	enemy.died.emit()
	die_timer.start(fuse_time)

func physics_update(delta: float) -> void:
	enemy.apply_central_force(
		Vector2.from_angle(enemy.global_rotation) * enemy.linear_velocity.length()
	)
	
	shake_amount += 10.0 * delta
	
	enemy.offset = Vector2(
		randf() * shake_amount,
		randf() * shake_amount
	)

func _on_health_has_died() -> void:
	if not is_active:
		enemy.health_indicator.kill()
		state_machine.transition_to("Die")


func _on_die_timer_timeout() -> void:
	enemy.bleeder.bleed(enemy.health.max_health, 2.0)
	enemy.weapon_handler.shoot()
	enemy.hide()
	await get_tree().create_timer(2.0, false).timeout
	enemy.queue_free()
