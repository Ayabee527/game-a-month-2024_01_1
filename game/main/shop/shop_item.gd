class_name ShopItem
extends Button

signal hovered()
signal unhovered()
signal confirmed()

@export var upgrade: RogueUpgrade

var confirming: bool = false

func _ready() -> void:
	if upgrade:
		icon = upgrade.upgrade_icon
		add_theme_color_override("icon_normal_color", upgrade.upgrade_color)
		add_theme_color_override("icon_hover_color", upgrade.upgrade_color)
		add_theme_color_override("icon_focus_color", upgrade.upgrade_color)
		add_theme_color_override("icon_pressed_color", upgrade.upgrade_color)
		add_theme_color_override("icon_hover_pressed_color", upgrade.upgrade_color)
	bounce()

func bounce() -> void:
	pivot_offset = size / 2.0
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		self, "scale", Vector2.ONE, 0.25
	).from( Vector2(2.0, 0.5) )
	tween.tween_property(
		self, "rotation_degrees", 0.0, 0.25
	).from( 45.0 )

func _on_mouse_entered() -> void:
	if confirming:
		return
	
	hovered.emit()
	pivot_offset = size / 2.0
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		self, "scale", Vector2.ONE * 1.2, 0.25
	).from( Vector2(2.0, 0.5) )


func _on_mouse_exited() -> void:
	if confirming:
		return
	
	unhovered.emit()
	pivot_offset = size / 2.0
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		self, "scale", Vector2.ONE, 0.25
	)


func _on_pressed() -> void:
	confirmed.emit()
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		self, "scale", Vector2.ONE * 1.2, 0.25
	).from( Vector2(2.0, 0.5) )
	release_focus()
