extends Node

signal points_updated(new_points: int)
signal point_mult_updated(new_point_mult: float)

var points: int = 0: set = set_points
var point_multiplier: float = 1.0: set = set_point_mult

func set_points(new_points: int) -> void:
	points = max(0, new_points)
	points_updated.emit(new_points)

func set_point_mult(new_point_mult: float) -> void:
	point_multiplier = max(1.0, new_point_mult)
	point_mult_updated.emit(new_point_mult)
