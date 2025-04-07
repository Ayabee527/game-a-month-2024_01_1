class_name EnemyTether
extends RigidBody2D

signal died()

@export var default_color: Color = Color.RED
@export var max_speed: float = 700.0

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var hurtbox: Hurtbox
@export var health: Health
@export var health_indicator: HealthIndicator
@export var player_tracker: PlayerTracker
@export var sprite: HeightSprite
@export var shadow: Shadow
@export var bleeder: EntityBleeder
@export var hurt_sfx: AudioStreamPlayer2D
@export var pointer: Marker2D
@export var weapon_handler: WeaponHandler

var player: Player

var color: Color

func _ready() -> void:
	color = default_color
	sprite.modulate = color
	sprite.hurt_color = color.inverted()
	
	player = get_tree().get_first_node_in_group("player")
	look_at(player.global_position)

func _process(delta: float) -> void:
	sprite.rotation_degrees += 340.0 * delta
	shadow.rotation_degrees += 340.0 * delta

func _physics_process(delta: float) -> void:
	pointer.global_position = player.global_position
	pointer.look_at(global_position)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	#return
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	var hurt_amount := roundi( (damage + RogueHandler.damage_plus) )
	health.hurt(hurt_amount)
	
	RogueHandler.trigger_style(
		global_position, "", hurt_amount
	)
	
	if health.health <= 0:
		if hitbox.owner is ExplosionAttack:
			RogueHandler.trigger_style(
				global_position, "EXPLODED!", 10
			)
		if hitbox.owner is LaserAttack:
			RogueHandler.trigger_style(
				global_position, "BLASTED!", 5
			)


func _on_hurtbox_knocked_back(knockback: Vector2) -> void:
	apply_central_impulse(knockback)

func _on_health_was_hurt(new_health: int, amount: int) -> void:
	MainCam.shake(10.0, 10.0, 5.0)
	
	health_indicator.update_health(health.health, health.max_health)
	player_tracker.update_health(health.health, health.max_health)
	bleeder.bleed(amount, 1.0, 20)
	
	sprite.play_hurt()
	
	sprite.squish(
		0.5, 5.0, true, false
	)
	hurt_sfx.play()
