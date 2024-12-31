class_name Player
extends RigidBody2D

signal died()

@export var default_color: Color = Color.WHITE
@export var move_speed: float = 600.0
@export var max_speed: float = 225.0
@export_range(0.0, 1.0) var camera_lean_amount: float = 0.25

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var health: Health
@export var health_indicator: HealthIndicator
@export var blood_pointer: BloodPointer
@export var sprite: HeightSprite
@export var shadow: Shadow
@export var trail: GPUParticles2D
@export var camera_lean: Marker2D
@export var weapon_handler: WeaponHandler
@export var bleeder: EntityBleeder
@export var draw_control: Marker2D
@export var hurt_sfx: AudioStreamPlayer2D
@export var blood_detect_coll: CollisionShape2D

var color: Color = Color.WHITE

var dashing: bool = false
var is_invinc: bool = false

func _ready() -> void:
	color = default_color
	sprite.modulate = default_color
	sprite.hurt_color = Color("e30035")
	grab_camera()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		weapon_handler.firing = true
	if Input.is_action_just_released("left_click"):
		weapon_handler.firing = false

func toggle_invinc(invinc: bool) -> void:
	is_invinc = invinc
	hurt_coll_shape.set_deferred("disabled", invinc)

func _process(delta: float) -> void:
	lean_camera()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not dashing:
		state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func grab_camera() -> void:
	MainCam.target = camera_lean

func lean_camera() -> void:
	var lean_point := (
		((1.0 - camera_lean_amount) * global_position)
		+ (camera_lean_amount * get_global_mouse_position())
	)
	camera_lean.global_position = lean_point

func set_weapons(new_weapons: Array[Weapon]) -> void:
	weapon_handler.weapons = new_weapons

func get_move_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	MainCam.shake(25.0, 10.0, 5.0)
	MainCam.hitstop(0.05, 0.75)
	
	health.hurt(damage)
	health_indicator.update_health(health.health, health.max_health)
	bleeder.bleed(damage, 2.0, 40)
	blood_detect_coll.set_deferred("disabled", true)
	blood_pointer.bleed(
		RogueHandler.points * 0.1, 300, 500.0, 5.0, 56.0
	)
	RogueHandler.points -= RogueHandler.points * 0.1
	
	sprite.squish(
		1.0, 5.0, true, false
	)
	hurt_sfx.play()
	
	await get_tree().create_timer(0.5, false).timeout
	blood_detect_coll.set_deferred("disabled", false)


func _on_hurtbox_knocked_back(knockback: Vector2) -> void:
	apply_central_impulse(knockback)


func _on_weapon_handler_recoiled(recoil: Vector2) -> void:
	apply_central_impulse(recoil)
	sprite.squish(
		0.5, 2.5, true, false
	)

func _on_blood_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("blood_points"):
		body = body as BloodPoint
		RogueHandler.last_point_color = body.color
		RogueHandler.points += 1
