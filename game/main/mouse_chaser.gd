extends Marker2D

@export var player: Player

@export var seeing_red_I: WeaponHandler
@export var seeing_green_I: WeaponHandler
@export var seeing_blue_I: WeaponHandler

func _physics_process(delta: float) -> void:
	global_position = player.global_position
	look_at(get_global_mouse_position())

func _on_player_point_grabbed(point_color: Color) -> void:
	match point_color:
		Color.RED:
			if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.SEEING_RED_I):
				seeing_red_I.shoot()
		Color.GREEN:
			if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.SEEING_GREEN_I):
				seeing_green_I.shoot()
		Color.BLUE:
			if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.SEEING_BLUE_I):
				seeing_blue_I.shoot()
