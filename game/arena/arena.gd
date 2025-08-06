class_name Arena
extends Area2D

signal resize_started(radius: float)
signal resize_finished(radius: float)
signal punishing_set(new_punishing: bool)

@export var color: Color = Color.TRANSPARENT:
	set = set_color
@export var radius: float = 1024.0:
	set = set_radius

@export_group("Inner Dependencies")
@export var border: Line2D
@export var highlight: Polygon2D
@export var collision: CollisionShape2D

var last_radius: float = 1024.0
var detail: int = 128
var punishing: bool = false:
	set = set_punishing

func _ready() -> void:
	update_arena(radius)

func set_color(new_color: Color) -> void:
	color = new_color
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		border, "default_color",
		color, 1.5
	)
	tween.tween_property(
		highlight, "color",
		Color(color.r, color.g, color.b, 0.25), 1.5
	)

func set_radius(new_radius: float) -> void:
	radius = new_radius
	resize_started.emit(radius)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	tween.tween_method(
		update_arena, last_radius, radius, 1.5
	) 
	last_radius = radius
	await tween.finished
	resize_finished.emit(radius)

func update_arena(new_radius: float) -> void:
	var points := PackedVector2Array()
	for i: int in range(detail):
		var ang: float = (float(i) / detail) * TAU
		var point: Vector2 = Vector2.from_angle(ang) * new_radius
		points.append(point)
	border.points = points
	highlight.polygon = points
	
	var shape := collision.shape as CircleShape2D
	shape.radius = new_radius
	collision.shape = shape

func set_punishing(new_punishing: bool) -> void:
	punishing = new_punishing
	punishing_set.emit(punishing)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		punishing = false


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		punishing = true
