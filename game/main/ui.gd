extends CanvasLayer

@export var point_count: RichTextLabel
@export var wave_count: RichTextLabel

var waves: int = 1

func _ready() -> void:
	waves = 1
	if not RogueHandler.points_updated.is_connected(update_points):
		RogueHandler.points_updated.connect(update_points)

func update_points(new_points: int) -> void:
	point_count.text = "[wave][shake]BITS: " + str(new_points)
	point_count.pivot_offset = point_count.size / 2.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		point_count, "scale", Vector2.ONE, 0.25
	).from( Vector2(1.5, 0.67) )


func _on_enemy_handler_wave_cleared(size: int) -> void:
	waves += 1
	var text_color: Color = Color.WHITE
	wave_count.text = "[wave]WAVE " + str(waves) + "/60"
	if waves % 15 == 0:
		text_color = Color.RED
		wave_count.text = "[wave][shake]WAVE " + str(waves) + "/60"
	elif waves % 5 == 0:
		text_color = Color.GREEN
	
	wave_count.pivot_offset = wave_count.size / 2.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		wave_count, "scale", Vector2.ONE, 4.0
	).from( Vector2(2.0, 2.0) )
	tween.tween_property(
		wave_count, "modulate", text_color, 4.0
	).from( Color.YELLOW )
