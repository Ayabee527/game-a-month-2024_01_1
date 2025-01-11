class_name StyleText
extends RichTextLabel

@export var style_text: String
@export var fresh_time: float = 0.5
@export var linger_time: float = 5.0

@export var fresh_timer: Timer

var tween: Tween

func _ready() -> void:
	text = "[center]" + style_text
	set_anchors_preset(Control.PRESET_CENTER)
	await get_tree().process_frame
	pivot_offset = size / 2.0
	fresh_timer.start(fresh_time)
	
	var rot_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	rot_tween.set_parallel()
	rot_tween.tween_property(
		self, "rotation_degrees",
		randf_range(-30, 30), 0.5
	)
	rot_tween.tween_property(
		self, "global_position",
		global_position + (Vector2.from_angle(TAU * randf()) * randf_range(0, 24.0)), 0.5
	)
	rot_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	rot_tween.tween_property(
		self, "scale",
		Vector2.ONE, 0.5
	).from( Vector2(2.0, 2.0) )
	rot_tween.play()

func _on_fresh_timer_timeout() -> void:
	if tween != null:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "modulate:a",
		0.5, 1.0
	)
	tween.play()
	await tween.finished
	if tween != null:
		tween.stop()
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "modulate:a",
		0.0, linger_time
	)
	tween.play()
	await tween.finished
	queue_free()
