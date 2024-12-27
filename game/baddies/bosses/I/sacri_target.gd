extends Marker2D

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_circle(
		Vector2.ZERO, 8.0, Color.RED, false, 3.0
	)
