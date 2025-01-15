extends Node

const STYLE_TEXT = preload("res://components/style_text/style_text.tscn")

@export var player: Player
@export var world: Node2D

func _ready() -> void:
	if not RogueHandler.style_triggered.is_connected(display_style):
		RogueHandler.style_triggered.connect(display_style)

func display_style(pos: Vector2, style_name: String, points_inc: int) -> void:
	var style_text = STYLE_TEXT.instantiate()
	style_text.global_position = pos
	var point_tell: String = ""
	if points_inc > 0:
		point_tell = " [color=yellow]+" + str(points_inc) + "[/color]"
	if points_inc < 0:
		point_tell = " [color=red]" + str(points_inc) + "[/color]"
	style_text.style_text = style_name + point_tell
	world.add_child(style_text)
	

# TODO: DODGE UPGRADE, EXPLODE PAYLOAD UPGRADE, MAGE WEAPON UPGRADE
