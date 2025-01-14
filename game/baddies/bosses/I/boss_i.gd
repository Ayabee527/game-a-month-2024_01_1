class_name BossI
extends RigidBody2D

signal color_set(new_color: Color)
signal died()

@export var max_speed: float = 50.0

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var hit_coll_shape: CollisionShape2D
@export var hurtbox: Hurtbox
@export var hitbox: Hitbox
@export var health: Health
@export var health_indicator: HealthIndicator
@export var player_tracker: PlayerTracker
@export var sprite: HeightSprite
@export var shadow: Shadow
@export var bleeder: EntityBleeder
@export var hurt_sfx: AudioStreamPlayer2D
@export var boss_music: AudioStreamPlayer

var player: Player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	#look_at(player.global_position)

func _physics_process(delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	return
	#state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func set_color(color: Color) -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		sprite, "modulate", color, 1.0
	)
	tween.tween_property(
		sprite, "hurt_color", color.inverted(), 1.0
	)
	tween.tween_property(
		bleeder, "blood_color", color, 1.0
	)
	tween.tween_property(
		player_tracker, "color", color, 1.0
	)
	tween.tween_property(
		health_indicator, "hurt_color", color, 1.0
	)
	tween.tween_property(
		health_indicator, "outline_color", color, 1.0
	)
	
	await tween.finished
	color_set.emit(color)

func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	MainCam.shake(10.0, 10.0, 5.0)
	
	health.hurt( roundi( (damage + RogueHandler.damage_plus) * (1.0 + RogueHandler.damage_mult) ) )
	health_indicator.update_health(health.health, health.max_health)
	player_tracker.update_health(health.health, health.max_health)
	bleeder.bleed(damage, 2.0, 40)
	
	sprite.play_hurt()
	sprite.squish(
		0.5, 2.0, true, false
	)
	hurt_sfx.play()


func _on_hurtbox_knocked_back(knockback: Vector2) -> void:
	apply_central_impulse(knockback)

func _on_height_sprite_height_changed(new_height: float) -> void:
	hitbox.height = new_height
	hurtbox.height = new_height
	hurt_coll_shape.position = sprite.offset
	health_indicator.position = sprite.offset
	player_tracker.position = sprite.offset


func _on_mage_shot_recoiled(recoil: Vector2) -> void:
	apply_central_impulse(recoil)
	sprite.squish(
		0.5, 1.5, true, true
	)

func _on_bullet_hell_fired() -> void:
	sprite.squish(
		0.5, 1.5, true, true
	)
