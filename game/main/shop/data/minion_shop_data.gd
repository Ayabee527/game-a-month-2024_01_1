class_name MinionShopData
extends Resource

@export var minion_name: String
@export_multiline var minion_desc: String
@export var minion_scene: PackedScene # Used to spawn different kinds of minions easily
@export var texture: Texture2D
@export var base_price: int = 50
