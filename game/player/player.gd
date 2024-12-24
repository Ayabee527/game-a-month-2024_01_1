class_name Player
extends RigidBody2D

signal died()

@export var default_color: Color = Color.WHITE
@export var move_speed: float = 600.0
@export var max_speed: float = 225.0
@export_range(0.0, 1.0) var camera_lean_amount: float = 0.25

@export var sides: int = 3
@export var radius: float = 4.0
@export var tail_radius: float = 2.0

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var health: Health
@export var health_indicator: HealthIndicator
@export var trail: GPUParticles2D
@export var camera_lean: Marker2D
@export var weapon_handler: WeaponHandler
@export var bleeder: EntityBleeder

var hull_shape: PackedVector2Array
var hull_outline: PackedVector2Array

var tail_shape: PackedVector2Array
var tail_outline: PackedVector2Array

var color: Color = Color.WHITE

var dashing: bool = false

func _ready() -> void:
	color = default_color
	MainCam.target = camera_lean
	
	hull_shape = Util.generate_polygon(sides, radius, true)
	hull_outline = Util.generate_polygon(sides, radius + 2.0, true)
	
	tail_shape = Util.generate_polygon(sides, tail_radius, true, Vector2(-radius - 2.0, 0), 180.0)
	tail_outline = Util.generate_polygon(sides, tail_radius + 2.0, true, Vector2(-radius - 2.0, 0), 180)
	
	var coll := CircleShape2D.new()
	coll.radius = radius
	coll_shape.shape = coll
	var hurt_coll := CircleShape2D.new()
	hurt_coll.radius = radius - 0.5
	hurt_coll_shape.shape = hurt_coll

func _physics_process(delta: float) -> void:
	var new_transform = global_transform.looking_at(get_global_mouse_position())
	global_transform = global_transform.interpolate_with(
		new_transform, 10.0 * delta
	)
	
	if Input.is_action_just_pressed("left_click"):
		weapon_handler.firing = true
	if Input.is_action_just_released("left_click"):
		weapon_handler.firing = false

func _process(delta: float) -> void:
	lean_camera()
	
	queue_redraw()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not dashing:
		state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func _draw() -> void:
	#draw_circle(
		#Vector2.ZERO, radius + 2.0, Util.BG_COLOR, true
	#)
	#draw_circle(
		#Vector2.ZERO, radius, Util.BORDER_COLOR, true
	#)
	
	draw_hull()
	draw_tail()

func draw_hull() -> void:
	draw_colored_polygon(
		hull_outline, Util.BG_COLOR
	)
	draw_polyline(
		hull_shape, color, 1.0
	)

func draw_tail() -> void:
	draw_colored_polygon(
		tail_outline, Util.BG_COLOR
	)
	draw_colored_polygon(
		tail_shape, color
	)

func lean_camera() -> void:
	var lean_point := (
		((1.0 - camera_lean_amount) * global_position)
		+ (camera_lean_amount * get_global_mouse_position())
	)
	camera_lean.global_position = lean_point

func get_move_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	MainCam.shake(25.0, 10.0, 5.0)
	MainCam.hitstop(0.05, 0.75)
	
	health.hurt(damage)
	health_indicator.update_health(health.health, health.max_health)
	bleeder.bleed(damage)
	
	color = Color("e30035")
	trail.modulate = color
	await get_tree().create_timer(invinc_time, false).timeout
	color = default_color
	trail.modulate = color


func _on_hurtbox_knocked_back(knockback: Vector2) -> void:
	apply_central_impulse(knockback)


func _on_weapon_handler_recoiled(recoil: Vector2) -> void:
	apply_central_impulse(recoil)
