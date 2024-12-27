class_name HealthIndicator
extends Node2D

@export var entity_name: String = "ENTITY"
@export var start_angle: float = 0.0
@export var radius: float = 12.0
@export var name_radius: float = 6.0
#@export var hurt_color: Color = Color(1, 0, 0, 0.2)
@export var hurt_color: Color = Color(1, 0, 0, 0.2): set = set_hurt_color
@export var outline_color: Color = Color(1, 0, 0, 0.2): set = set_outline_color

var health_fraction: float

var name_font: Font
var leet_name: String

func _ready() -> void:
	name_font = load("res://assets/fonts/m3x6.ttf")

func _process(delta: float) -> void:
	queue_redraw()
	
	if randf() <= 0.1:
		generate_leet()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, -global_rotation)
	draw_circle(
		Vector2.ZERO, (radius - 2.0) * health_fraction, hurt_color, true
	)
	
	draw_circle(
		Vector2.ZERO, radius, outline_color, false, 1.0
	)
	
	draw_arc(
		Vector2.ZERO, radius - 2.0, deg_to_rad(start_angle),
		deg_to_rad(start_angle) + (health_fraction * TAU), 64,
		Color(1, 0, 0, 0.5), 2.0
	)
	
	draw_string(
		name_font, Vector2(1, -1) * name_radius, leet_name.to_upper(),
		HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color(1, 1, 1, 0.75)
	)

func set_hurt_color(new_color: Color):
	new_color.a = 0.2
	hurt_color = new_color

func set_outline_color(new_color: Color):
	new_color.a = 0.2
	outline_color = new_color

func update_health(new_health: int, max_health: int) -> void:
	health_fraction = ( float(max_health - new_health) / max_health )

func kill() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "modulate:a", 0.0, 1.0
	)

func generate_leet() -> void:
	leet_name = ""
	for char: String in entity_name.to_upper():
		if randf() <= 0.4:
			match char:
				"A":
					leet_name += "@"
				"E":
					leet_name += "3"
				"G":
					leet_name += "6"
				"I":
					leet_name += "1"
				"O":
					leet_name += "0"
				"S":
					leet_name += "5"
				"T":
					leet_name += "7"
				_:
					leet_name += char
		else:
			leet_name += char
