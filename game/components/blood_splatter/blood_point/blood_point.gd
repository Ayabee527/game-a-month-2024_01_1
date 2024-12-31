class_name BloodPoint
extends RigidBody2D

signal grabbed(target_group: String)

@export var color: Color = Color.WHITE
@export var chase_radius: float = 128.0
@export var spin_speed: float = -270.0
@export var chase_speed: float = 1500.0
@export var max_speed: float = 1000.0
@export var life_time: float = 1.0
@export var max_blinks: int = 3
@export var target_group: String = "player"

@export_group("Inner Dependencies")
@export var sprite: HeightSprite
@export var shadow: Shadow
@export var health_indicator: HealthIndicator
@export var grab_sfx: AudioStreamPlayer
@export var bleeder: EntityBleeder
@export var coll_shape: CollisionShape2D
@export var chase_coll_shape: CollisionShape2D
@export var grab_coll_shape: CollisionShape2D

@export var life_timer: Timer
@export var blink_timer: Timer

var chasing: bool = false
var target: Node2D
var off: bool = false
var blinks: int = 0

func _ready() -> void:
	sprite.modulate = color
	health_indicator.hurt_color = color
	health_indicator.outline_color = color
	bleeder.blood_color = color
	
	var chase_shape := CircleShape2D.new()
	chase_shape.radius = chase_radius
	chase_coll_shape.shape = chase_shape
	life_timer.start(life_time)
	
	await get_tree().create_timer(life_time * 0.25, false).timeout
	chase_coll_shape.set_deferred("disabled", false)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func _physics_process(delta: float) -> void:
	sprite.rotation_degrees += spin_speed * delta
	
	if chasing:
		var new_transform = global_transform.looking_at(target.global_position)
		global_transform = global_transform.interpolate_with(
			new_transform, 100.0 * delta
		)
		
		apply_central_force(
			Vector2.from_angle(global_rotation) * chase_speed
		)

func grab() -> void:
	sprite.hide()
	shadow.hide()
	MainCam.shake(9.0, 5.0, 5.0)
	health_indicator.kill()
	grab_sfx.play()
	bleeder.bleed(1, 1.0, 20)
	coll_shape.set_deferred("disabled", true)
	chase_coll_shape.set_deferred("disabled", true)
	grab_coll_shape.set_deferred("disabled", true)
	set_deferred("freeze", true)
	await get_tree().create_timer(1.0, false).timeout
	queue_free()

func expire() -> void:
	blink_timer.stop()
	sprite.hide()
	shadow.hide()
	health_indicator.kill()
	set_deferred("freeze", true)
	coll_shape.set_deferred("disabled", true)
	chase_coll_shape.set_deferred("disabled", true)
	grab_coll_shape.set_deferred("disabled", true)
	await get_tree().create_timer(1.0, false).timeout
	queue_free()

func blink(new_off: bool) -> void:
	off = new_off
	if off:
		blinks += 1
		if blinks >= max_blinks:
			expire()
		else:
			sprite.hide()
			shadow.hide()
	if not off:
		sprite.show()
		shadow.show()

func _on_chase_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group(target_group) and not chasing:
		target = body
		chasing = true
		blink_timer.stop()
		life_timer.stop()
		blink(false)


func _on_life_timer_timeout() -> void:
	blink_timer.start()


func _on_blink_timer_timeout() -> void:
	blink(not off)

func _on_grab_detect_area_entered(area: Area2D) -> void:
	if area.is_in_group(target_group):
		grabbed.emit(target_group)
		grab()
