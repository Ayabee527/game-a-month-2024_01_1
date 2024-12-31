class_name UpgradeShopData
extends Resource

@export var upgrade_name: String
@export_multiline var upgrade_desc: String
@export var upgrade_id: int = 0 # Determine which upgrade to trigger in UpgradeHandler using ID
@export var texture: Texture2D
@export var base_price: int = 50
