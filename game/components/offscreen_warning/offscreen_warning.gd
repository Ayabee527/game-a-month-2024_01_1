class_name OffscreenWarning
extends VisibleOnScreenNotifier2D

@export var color: Color
@export var out_color: Color
@export var radius: float = 8.0
@export var draw_dist: float = 32.0

var seen: bool = false
var player: Player

var draw_scale: float = 1.0

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.died.connect(_on_player_died)
	
	await owner.ready
	color.a = 1.0

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not seen:
		var dir_from_player: Vector2 = (
			player.global_position.direction_to(global_position)
		)
		var dist_from_player: float = (
			player.global_position.distance_to(global_position)
		)
		var warn_position := dir_from_player * draw_dist
		
		var real_radius: float = radius * (128.0 / dist_from_player)
		draw_set_transform(Vector2.ZERO, -global_rotation, Vector2.ONE * draw_scale)
		draw_circle(
			(player.global_position - global_position) + warn_position,
			real_radius + 4.0, Util.BG_COLOR, true
		)
		draw_circle(
			(player.global_position - global_position) + warn_position,
			real_radius, color, false, 2.0
		)

func _on_screen_entered() -> void:
	seen = true


func _on_screen_exited() -> void:
	seen = false

func kill() -> void:
	seen = true

func _on_player_died() -> void:
	kill()
