class_name EntityBleeder
extends Node2D

const SPLATTER = preload("res://components/blood_splatter/blood_splatter.tscn")

@export var blood_color: Color = Color.RED

var world: Node2D

func _ready() -> void:
	world = get_tree().get_first_node_in_group("world")

func bleed(bleeds: int, size: float = 1.0) -> void:
	for i: int in bleeds:
		var splatter = SPLATTER.instantiate()
		splatter.amount_ratio = randf_range(
			clamp(bleeds * 0.2, 0.2, 1.0),
			1.0
		)
		splatter.global_position = global_position
		splatter.modulate = blood_color
		splatter.scale = Vector2.ONE * size
		world.add_child(splatter)
		splatter.restart()
