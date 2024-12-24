class_name EnemyKamikaze
extends RigidBody2D

signal died()

@export var default_color: Color = Color.RED
@export var max_speed: float = 200.0

@export var sides: int = 3
@export var radius: float = 4.0

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var health: Health
@export var health_indicator: HealthIndicator
@export var trail: Trail
@export var weapon_handler: WeaponHandler
@export var bleeder: EntityBleeder

var player: Player

var shape: PackedVector2Array
var outline: PackedVector2Array

var offset: Vector2 = Vector2.ZERO
var draw_rotation: float = 0.0

var color: Color

func _ready() -> void:
	color = default_color
	trail.modulate = color
	
	player = get_tree().get_first_node_in_group("player")
	
	shape = Util.generate_polygon(sides, radius, true)
	outline = Util.scale_polygon(shape, ((radius + 2.0) / radius))
	
	var coll := CircleShape2D.new()
	coll.radius = radius
	coll_shape.shape = coll
	var hurt_coll := CircleShape2D.new()
	hurt_coll.radius = radius + 2.0
	hurt_coll_shape.shape = hurt_coll

func _process(delta: float) -> void:
	draw_rotation = fposmod(draw_rotation, TAU)
	
	queue_redraw()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func _draw() -> void:
	draw_set_transform(offset, draw_rotation)
	draw_colored_polygon(
		outline, Util.BG_COLOR
	)
	#draw_polyline(
		#shape, color, 1.0
	#)
	draw_colored_polygon(
		shape, color
	)
	draw_set_transform(offset, -draw_rotation)
	#draw_polyline(
		#shape, color, 1.0
	#)
	draw_colored_polygon(
		shape, color
	)


func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	MainCam.shake(10.0, 10.0, 5.0)
	
	health.hurt(damage)
	health_indicator.update_health(health.health, health.max_health)
	bleeder.bleed(damage)
	
	color = default_color.inverted()
	trail.modulate = color
	await get_tree().create_timer(invinc_time, false).timeout
	color = default_color
	trail.modulate = color


func _on_hurtbox_knocked_back(knockback: Vector2) -> void:
	apply_central_impulse(knockback)
