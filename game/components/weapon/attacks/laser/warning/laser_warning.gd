class_name LaserWarning
extends Marker2D

signal fired()

@export var active: bool = true:
	set = set_active

@export var muzzle_dist: float = 8.0
@export var color: Color = Color.WHITE
@export var alpha: float = 0.3
@export var width: float = 8.0

@export var cool_down: float = 4.0
@export var warn_time: float = 2.0

@export var cool_timer: Timer

var draw_size: float = 0.0
var back_size: float = 0.0

var tween: Tween

func _ready() -> void:
	if active:
		warn()

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var draw_color: Color = color
	draw_color.a = alpha
	#draw_circle(
		#Vector2.RIGHT * muzzle_dist, draw_size * 1.25, draw_color, true
	#)
	draw_line(
		Vector2.ZERO, Vector2.RIGHT * 1024.0, draw_color, back_size
	)
	draw_line(
		Vector2.ZERO, Vector2.RIGHT * 1024.0, draw_color, draw_size
	)

func set_active(new_active: bool) -> void:
	active = new_active
	if active:
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(
			self, "back_size", width, 0.2
		).from(0.0)
		cool_timer.start(cool_down)
		warn()
	else:
		if tween != null:
			tween.stop()
		tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.set_parallel()
		tween.tween_property(
			self, "draw_size", 0.0, 0.2
		)
		tween.tween_property(
			self, "back_size", 0.0, 0.2
		)

func warn() -> void:
	tween = create_tween()
	tween.tween_property(
		self, "draw_size", width, warn_time
	).from(0.0)
	await tween.finished
	fired.emit()
	
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "draw_size", 0.0, 0.2
	)

func _on_cool_timer_timeout() -> void:
	if active:
		cool_timer.start(cool_down)
		warn()
