extends CanvasLayer

@export var point_count: RichTextLabel

func _ready() -> void:
	if not RogueHandler.points_updated.is_connected(update_points):
		RogueHandler.points_updated.connect(update_points)
	if not RogueHandler.point_color_updated.is_connected(update_point_color):
		RogueHandler.point_color_updated.connect(update_point_color)

func update_points(new_points: int) -> void:
	point_count.text = "[wave][shake]POINTS: " + str(new_points)
	point_count.pivot_offset = point_count.size / 2.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		point_count, "scale", Vector2.ONE, 0.25
	).from( Vector2(1.5, 0.67) )

func update_point_color(new_color: Color) -> void:
	point_count.modulate = new_color
