class_name ShopMenu
extends PanelContainer

@export var open_jingle_sfx: AudioStreamPlayer
@export var shop_theme: AudioStreamPlayer
@export var normal_music: AudioStreamPlayer
@export var checker_board: Parallax2D

func _ready() -> void:
	scale = Vector2(1, 0)

func open() -> void:
	pivot_offset = Vector2(128, 256)
	scale = Vector2(1, 0)
	checker_board.modulate.a = 0.0
	await get_tree().create_timer(1.0, false).timeout
	open_jingle_sfx.play()
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		normal_music, "pitch_scale", 0.01, 2.0
	).from(1.0)
	await tween.finished
	normal_music.stream_paused = true
	
	shop_theme.playing = true
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(
		self, "scale", Vector2.ONE, 2.0
	).from( Vector2(1, 0) )
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		checker_board, "modulate:a", 1.0, 1.0
	).from(0.0)
	await tween.finished
	get_tree().paused = true
