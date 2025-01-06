extends Marker2D

@export var seeing_red_I: WeaponHandler
@export var seeing_green_I: WeaponHandler
@export var seeing_blue_I: WeaponHandler

func _on_player_point_grabbed(point_color: Color) -> void:
	match point_color:
		Color.RED:
			if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.SEEING_RED_I):
				if randf() <= 0.1:
					seeing_red_I.shoot()
		Color.GREEN:
			if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.SEEING_GREEN_I):
				if randf() <= 0.1:
					seeing_green_I.shoot()
		Color.BLUE:
			if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.SEEING_BLUE_I):
				if randf() <= 0.1:
					seeing_blue_I.shoot()
