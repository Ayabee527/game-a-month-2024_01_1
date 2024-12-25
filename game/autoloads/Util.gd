extends Node

const BG_COLOR: Color = Color("0d0d0d")
const BORDER_COLOR: Color = Color.WHITE

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()

func generate_polygon(detail: int, radius: float, closed: bool = true, offset: Vector2 = Vector2.ZERO, rotation: float = 0.0) -> PackedVector2Array:
	var points := PackedVector2Array()
	for i: int in range(detail):
		var point := Vector2.from_angle( deg_to_rad(rotation) + (TAU * ( float(i) / detail ))) * radius
		points.append(point + offset)
	
	if closed:
		points.append(points[0])
	
	return points

func scale_polygon(polygon: PackedVector2Array, scale: float = 1.0) -> PackedVector2Array:
	var new_polygon := PackedVector2Array()
	for point: Vector2 in polygon:
		var new_point: Vector2 = point * scale
		new_polygon.append(new_point)
	
	return new_polygon

func squish(node: Node2D, squish_time: float, amount: float = 1.5, rotate: bool = true, flat: bool = true) -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	
	var squish_scale := Vector2(
		amount,
		(2.0 / amount)
	) if flat else Vector2(
		(2.0 / amount),
		amount
	)
	
	tween.tween_property(
		node, "global_scale", Vector2.ONE, squish_time
	).from(squish_scale)
	
	if rotate:
		tween.tween_property(
			node, "global_rotation_degrees", 0.0, squish_time
		).from(randf_range(-60, 60))
