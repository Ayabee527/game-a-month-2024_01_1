extends Node

const STYLE_TEXT = preload("res://components/style_text/style_text.tscn")

@export var player: Player
@export var world: Node2D

func _ready() -> void:
	if not RogueHandler.style_triggered.is_connected(display_style):
		RogueHandler.style_triggered.connect(display_style)

func display_style(style_name: String, _multiplier_inc: float) -> void:
	var style_text = STYLE_TEXT.instantiate()
	style_text.style_text = style_name
	world.add_child(style_text)
	
