class_name ShopMenu
extends PanelContainer

signal confirmed()

@export var open_jingle_sfx: AudioStreamPlayer
@export var shop_theme: AudioStreamPlayer
@export var normal_music: AudioStreamPlayer
@export var checker_board: Parallax2D
@export var tier_label: RichTextLabel
@export var points_label: RichTextLabel

var tier: int = 1
var tier_queued: bool = false

func _ready() -> void:
	position = Vector2(0, 256)
	await owner.ready
	if not RogueHandler.points_updated.is_connected(update_points):
		RogueHandler.points_updated.connect(update_points)

func update_points(new_points: int) -> void:
	points_label.text = "[wave]POINTS: " + str(new_points)
	points_label.pivot_offset = points_label.size / 2.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		points_label, "scale", Vector2.ONE, 0.25
	).from( Vector2(1.5, 0.67) )

func open() -> void:
	show()
	position = Vector2(0, 256)
	open_jingle_sfx.play()
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		normal_music, "pitch_scale", 0.01, 2.0
	).from(1.0)
	await tween.finished
	normal_music.stream_paused = true
	
	shop_theme.volume_db = -15
	shop_theme.playing = true
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(
		self, "position", Vector2.ZERO, 1.0
	).from( Vector2(0, 256) )
	await tween.finished
	get_tree().paused = true


func _on_confirm_pressed() -> void:
	get_tree().paused = false
	normal_music.stream_paused = false
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		shop_theme, "volume_db", linear_to_db(0), 2.0
	)
	tween.tween_property(
		normal_music, "pitch_scale", 1.0, 2.0
	).from(0.01)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(
		self, "position", Vector2(0, -256), 1.0
	).from( Vector2(0, 0) )
	await tween.finished
	shop_theme.playing = false
	hide()
	confirmed.emit()
