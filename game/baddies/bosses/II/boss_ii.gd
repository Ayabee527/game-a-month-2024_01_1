class_name BossII
extends RigidBody2D

signal color_set(new_color: Color)
signal died()

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
@export var boss_music_1: AudioStreamPlayer
@export var boss_music_2: AudioStreamPlayer

var phase: int = 0

var player: Player
var arena: Arena

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	arena = get_tree().get_first_node_in_group("arena")
	#look_at(player.global_position)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	pass

func set_color(color_1: Color) -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		sprite, "modulate", color_1, 1.0
	)
	tween.tween_property(
		sprite, "hurt_color", color_1.inverted(), 1.0
	)
	tween.tween_property(
		bleeder, "blood_color", color_1, 1.0
	)
	tween.tween_property(
		player_tracker, "color", color_1, 1.0
	)
	tween.tween_property(
		health_indicator, "hurt_color", color_1, 1.0
	)
	tween.tween_property(
		health_indicator, "outline_color", color_1, 1.0
	)
	
	await tween.finished
	color_set.emit(color_1)

func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	MainCam.shake(10.0, 10.0, 5.0)
	
	var hurt_amount := roundi( (damage + RogueHandler.damage_plus) )
	health.hurt(hurt_amount)
	health_indicator.update_health(health.health, health.max_health)
	player_tracker.update_health(health.health, health.max_health)
	bleeder.bleed(hurt_amount, 2.0, 40)
	
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
