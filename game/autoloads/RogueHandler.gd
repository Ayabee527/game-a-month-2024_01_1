extends Node

signal points_updated(new_points: int)
signal point_color_updated(new_point_color: Color)
signal point_mult_updated(new_point_mult: float)

var points: int = 0: set = set_points
var last_point_color: Color = Color.WHITE: set = set_point_color
var point_multiplier: float = 1.0: set = set_point_mult

func set_points(new_points: int) -> void:
	points = max(0, new_points)
	points_updated.emit(new_points)

func set_point_color(new_point_color: Color) -> void:
	last_point_color = new_point_color
	point_color_updated.emit(last_point_color)

func set_point_mult(new_point_mult: float) -> void:
	point_multiplier = max(1.0, new_point_mult)
	point_mult_updated.emit(new_point_mult)
