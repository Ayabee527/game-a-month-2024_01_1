class_name RogueUpgrade
extends Resource

@export var upgrade_name: String
@export_multiline var upgrade_desc: String
@export var upgrade_icon: Texture2D
@export var upgrade_color: Color = Color.WHITE
@export var upgrade_id: UpgradeHandler.UPGRADES
@export var base_price: int = 50
@export var upgrade_tier: int = 1
