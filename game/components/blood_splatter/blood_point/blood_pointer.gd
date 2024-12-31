class_name BloodPointer
extends Node2D

const BLOOD_POINT = preload("res://components/blood_splatter/blood_point/blood_point.tscn")

@export var blood_color: Color = Color.RED

var world: Node2D

func _ready() -> void:
	world = get_tree().get_first_node_in_group("world")

func bleed(points: int, min_push: float = 200.0, max_push: float = 300.0, life_time: float = 1.0, chase_radius: float = 128.0, target_group: String = "player") -> void:
	for i: int in roundi(points * RogueHandler.point_multiplier):
		var point = BLOOD_POINT.instantiate()
		point.global_position = global_position
		point.color = blood_color
		point.life_time = life_time
		point.target_group = target_group
		point.chase_radius = chase_radius
		world.add_child(point)
		point.apply_central_impulse(
			Vector2.from_angle(TAU * randf())
			* randf_range(min_push, max_push)
		)
