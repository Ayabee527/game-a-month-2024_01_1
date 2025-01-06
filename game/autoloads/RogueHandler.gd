extends Node

signal points_updated(new_points: int)
signal style_points_updated(new_style_points: int)
signal point_color_updated(new_point_color: Color)

signal style_triggered(style_name: String)
signal style_tier_updated(style_tier: int, tier_percent: float)

const STYLE_TIERS = [
	0,
	200,
	400,
	600,
	1000,
	1500,
]

var points: int = 0: set = set_points
var last_point_color: Color = Color.WHITE: set = set_point_color
var style_tier: int = 1
var style_points: int = 0

func set_points(new_points: int) -> void:
	points = max(0, new_points)
	points_updated.emit(points)

func set_style_points(new_style_points: int) -> void:
	style_points = max(0, new_style_points)
	style_points_updated.emit(style_points)

func set_point_color(new_point_color: Color) -> void:
	last_point_color = new_point_color
	point_color_updated.emit(last_point_color)

func trigger_style(style_name: String, points_inc: int) -> void:
	style_points += points_inc
	
	for i: int in range(STYLE_TIERS.size()):
		var min_tier_points = STYLE_TIERS[i]
		if style_points < min_tier_points:
			style_tier = i
			# calculate percent to next tier
			var max_tier_points = STYLE_TIERS[i + 1]
	
	style_triggered.emit(style_name)
