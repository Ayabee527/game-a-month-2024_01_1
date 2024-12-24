class_name PlayerTracker
extends Node2D

signal killed()

@export var color: Color = Color(0.216, 0.216, 0.216, 0.25)
@export var width: float = 1.0

var player: Player
var health_fraction: float = 1.0
var draw_width: float = 0.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.died.connect(_on_player_died)
	
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "draw_width", width, 1.0
	).from(0.0)

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_target()

func kill() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "draw_width", 0.0, 1.0
	).from(width)
	await tween.finished
	killed.emit()
	

func draw_target() -> void:
	draw_set_transform(Vector2.ZERO, -global_rotation)
	
	draw_line(
		Vector2.ZERO, player.global_position - global_position,
		color, draw_width * health_fraction
	)

func update_health(new_health: int, max_health: int) -> void:
	health_fraction = float(new_health) / max_health

func _on_player_died() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "draw_width", 0.0, 1.0
	).from(width)
