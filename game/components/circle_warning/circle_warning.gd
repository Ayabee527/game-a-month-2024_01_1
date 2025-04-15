class_name CircleWarning
extends Marker2D

signal fired()

@export var warn_time: float = 1.0
@export var radius: float = 32.0
@export var color: Color = Color.WHITE
@export var alpha: float = 0.2

var draw_color: Color
var draw_size: float = 0.0
var warn_size: float = 0.0

var trans_time: float = 0.0

func _ready() -> void:
	draw_color = color
	draw_color.a = alpha
	trans_time = min(warn_time / 4.0, 0.2)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		self, "draw_size", 1.0, trans_time
	)
	warn()

func warn() -> void:
	var tween = create_tween()
	tween.tween_property(
		self, "warn_size", radius, warn_time
	)
	await tween.finished
	
	fired.emit()
	var tween2 = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween2.tween_property(
		self, "draw_size", 0.0, trans_time
	)
	await tween2.finished
	queue_free()

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * draw_size)
	
	draw_circle(
		Vector2.ZERO, radius, draw_color, true
	)
	draw_circle(
		Vector2.ZERO, warn_size, draw_color, true
	)
