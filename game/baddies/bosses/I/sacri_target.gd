extends Marker2D

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(
		Vector2.ZERO, 16.0, Color.RED, false, 4.0
	)
	draw_circle(
		Vector2.ZERO, 18.0, Color.RED, false, 1.0
	)
