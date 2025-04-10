class_name EnemySniper
extends RigidBody2D

signal died()

@export var default_color: Color = Color.GREEN
@export var max_speed: float = 250.0

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var hurtbox: Hurtbox
@export var health: Health
@export var health_indicator: HealthIndicator
@export var player_tracker: PlayerTracker
@export var sprite: HeightSprite
@export var shadow: Shadow
@export var weapon_handler: WeaponHandler
@export var bleeder: EntityBleeder
@export var hurt_sfx: AudioStreamPlayer2D
@export var laser_warning: LaserWarning

var player: Player

var color: Color
var warn_size: float = 0.0

func _ready() -> void:
	color = default_color
	sprite.modulate = color
	sprite.hurt_color = color.inverted()
	
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	pass
	#queue_redraw()

func _physics_process(delta: float) -> void:
	pass

func _draw() -> void:
	pass
	#draw_line(
		#Vector2.ZERO, Vector2.RIGHT * 1024.0, Color(0.2, 1, 0.2, 0.3), warn_size
	#)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
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


func _on_weapon_handler_recoiled(recoil: Vector2) -> void:
	apply_central_impulse(recoil)
	sprite.squish(
		0.5, 5.0, true, true
	)


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

func _on_height_sprite_height_changed(new_height: float) -> void:
	hurtbox.height = new_height
	hurt_coll_shape.position = sprite.offset
	health_indicator.position = sprite.offset
	player_tracker.position = sprite.offset
