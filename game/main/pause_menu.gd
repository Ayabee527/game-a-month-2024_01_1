extends PanelContainer

@export var enemy_handler: EnemyHandler

var blocked: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape"):
		if not blocked:
			if get_tree().paused:
				unpause()
			else:
				pause()

func pause() -> void:
	if not blocked:
		get_tree().paused = true
		show()
		#enemy_handler.music.volume_db = linear_to_db(1.0)
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(
			enemy_handler.music, "pitch_scale", 0.75, 1.0
		)

func unpause() -> void:
	if not blocked:
		get_tree().paused = false
		hide()
		#enemy_handler.music.volume_db = linear_to_db(1.0)
		var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		#tween.set_parallel()
		tween.tween_property(
			enemy_handler.music, "pitch_scale", 1.0, 1.0
		)

func _on_player_died() -> void:
	blocked = true

func _on_resume_pressed() -> void:
	unpause()


func _on_shop_menu_shop_opened() -> void:
	blocked = true


func _on_shop_menu_confirmed() -> void:
	blocked = false
