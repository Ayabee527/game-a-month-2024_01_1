class_name BloodPoint
extends RigidBody2D

@export var color: Color
@export var chase_radius: float = 16.0
@export var spin_speed: float = -270.0

@export_group("Inner Dependencies")
@export var sprite: HeightSprite
@export var health_indicator: HealthIndicator

var chasing: bool = false

func _ready() -> void:
	sprite.modulate = color
	health_indicator.hurt_color = color
	health_indicator.outline_color = color

func _physics_process(delta: float) -> void:
	sprite.global_rotation_degrees += spin_speed * delta

func grab() -> void:
	RogueHandler.points += 1
	sprite.hide()
	health_indicator.kill()
	set_deferred("freeze", true)
	await get_tree().create_timer(1.0, false).timeout
	queue_free()


func _on_chase_detect_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		chasing = true
