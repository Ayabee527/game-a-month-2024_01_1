class_name LaserWarn
extends Node2D

signal faded_in()
signal faded_out()

@export var color: Color = Color(1, 1, 1, 1)
@export var width: float = 2
@export var length: float = 1024

@export var fade_in_time: float = 0.1
@export var sustain_time: float = 1.0
@export var fade_out_time: float = 0.1

var state: int = 0

func _ready() -> void:
	fade_in()

func _draw() -> void:
	draw_circle(
		Vector2.ZERO, width * 1.5, color, true
	)
	draw_line(
		Vector2.ZERO, Vector2.RIGHT, color, width
	)

func fade_in() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "modulate:a", 1.0, fade_in_time
	).from(0.0)
	await tween.finished
	faded_in.emit()
	if state == 0:
		state = 1
		sustain()

func sustain() -> void:
	await get_tree().create_timer(sustain_time, false).timeout
	if state == 1:
		state = 2
		fade_out()

func fade_out() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "modulate:a", 0.0, fade_in_time
	)
	await tween.finished
	faded_out.emit()
	queue_free()
