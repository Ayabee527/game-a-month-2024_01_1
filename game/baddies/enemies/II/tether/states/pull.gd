extends EnemyTetherState

@export var max_pull_force: float = 500.0
@export var min_pull_force: float = 200.0

var pull_force: float = 300.0

func enter(_msg:={}) -> void:
	pull_force = min_pull_force
	enemy.weapon_handler.firing = true

func physics_update(delta: float) -> void:
	enemy.player.apply_central_force(
		enemy.player.global_position.direction_to(enemy.global_position) * pull_force
	)

func exit() -> void:
	enemy.weapon_handler.firing = false

func _on_health_was_hurt(new_health: int, amount: int) -> void:
	pull_force = lerp(
		min_pull_force, max_pull_force,
		1 - (new_health / enemy.health.max_health)
	)
