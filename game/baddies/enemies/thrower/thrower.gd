class_name EnemyThrower
extends RigidBody2D

signal died()

@export var default_color: Color = Color.GREEN
@export var max_speed: float = 150.0

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var health: Health
@export var health_indicator: HealthIndicator
@export var sprite: Sprite2D
@export var weapon_handler: WeaponHandler
@export var bleeder: EntityBleeder

var player: Player

var color: Color

func _ready() -> void:
	color = default_color
	sprite.modulate = color
	
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	weapon_handler.look_at(player.global_position)
	#weapon_handler.global_rotation += PI

func _process(delta: float) -> void:
	if player.global_position.x < global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	MainCam.shake(10.0, 10.0, 5.0)
	
	health.hurt(damage)
	health_indicator.update_health(health.health, health.max_health)
	bleeder.bleed(damage)
	
	color = default_color.inverted()
	sprite.modulate = color
	await get_tree().create_timer(invinc_time, false).timeout
	color = default_color
	sprite.modulate = color


func _on_hurtbox_knocked_back(knockback: Vector2) -> void:
	apply_central_impulse(knockback)


func _on_weapon_handler_recoiled(recoil: Vector2) -> void:
	apply_central_impulse(recoil)
