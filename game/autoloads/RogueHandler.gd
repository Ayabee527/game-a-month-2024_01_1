extends Node

signal points_updated(new_points: int)

signal style_triggered(pos: Vector2, style_name: String, points_inc: int)

var points: int = 0: set = set_points

func set_points(new_points: int) -> void:
	points = max(0, new_points)
	points_updated.emit(points)

func trigger_style(pos: Vector2, style_name: String, points_inc: int) -> void:
	points += points_inc
	
	style_triggered.emit(pos, style_name, points_inc)
