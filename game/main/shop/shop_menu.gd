class_name ShopMenu
extends PanelContainer

signal confirmed()

const SHOP_ITEM = preload("res://main/shop/shop_item.tscn")

@export var upgrades: Array[RogueUpgrade]

@export var open_jingle_sfx: AudioStreamPlayer
@export var shop_theme: AudioStreamPlayer
@export var normal_music: AudioStreamPlayer
@export var checker_board: Parallax2D
@export var tier_label: RichTextLabel
@export var points_label: RichTextLabel
@export var shop_holder: GridContainer
@export var equip_holder: GridContainer

@export var info_name: RichTextLabel
@export var info_cost: RichTextLabel
@export var info_desc: RichTextLabel
@export var info_panel: PanelContainer


var tier: int = 1
var tier_queued: bool = false

func _ready() -> void:
	position = Vector2(0, 256)
	await owner.ready
	if not RogueHandler.points_updated.is_connected(update_points):
		RogueHandler.points_updated.connect(update_points)

func restock() -> void:
	var possible_upgrades: Array[RogueUpgrade]
	for upgrade: RogueUpgrade in upgrades:
		if upgrade.upgrade_tier <= tier:
			possible_upgrades.append(upgrade)
	
	for child in shop_holder.get_children():
		child.queue_free()
	
	possible_upgrades.shuffle()
	var amount = tier + 2
	for i: int in amount:
		var item = SHOP_ITEM.instantiate()
		var chosen_upgrade: RogueUpgrade
		if possible_upgrades.size() > 1:
			chosen_upgrade = possible_upgrades.pop_back()
		else:
			chosen_upgrade = possible_upgrades.back()
		item.upgrade = chosen_upgrade
		shop_holder.add_child(item)
		item.hovered.connect(explain.bind(chosen_upgrade))
		item.unhovered.connect(unexplain)

func update_points(new_points: int) -> void:
	points_label.text = "[wave]POINTS: " + str(new_points)
	points_label.pivot_offset = points_label.size / 2.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		points_label, "scale", Vector2.ONE, 0.25
	).from( Vector2(1.5, 0.67) )

func open() -> void:
	unexplain()
	restock()
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

func buy(item: ShopItem) -> void:
	if item.price <= RogueHandler.points:
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(
			points_label, "modulate", Color.WHITE, 1.0
		).from(Color.GOLD)
	else:
		points_label.pivot_offset = points_label.size / 2.0
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.set_parallel()
		tween.tween_property(
			points_label, "scale", Vector2.ONE, 0.25
		).from( Vector2(1.5, 0.67) )
		tween.tween_property(
			points_label, "modulate", Color.WHITE, 1.0
		).from(Color.RED)

func explain(upgrade: RogueUpgrade) -> void:
	info_panel.pivot_offset = Vector2(
		info_panel.size.x / 2.0,
		info_panel.size.y
	)
	
	info_name.text = "[wave]" + upgrade.upgrade_name
	info_name.pivot_offset = info_name.size / 2.0
	
	info_cost.text = "[wave]COST: [color=gold]" + str(upgrade.base_price)
	info_cost.pivot_offset = info_cost.size / 2.0
	
	info_desc.text = "[wave]" + upgrade.upgrade_desc
	info_desc.pivot_offset = info_desc.size / 2.0
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		info_name, "scale", Vector2.ONE, 0.25
	).from( Vector2(2.0, 0.5) )
	tween.tween_property(
		info_cost, "scale", Vector2.ONE, 0.25
	).from( Vector2(2.0, 0.5) )
	tween.tween_property(
		info_desc, "scale", Vector2.ONE, 0.25
	).from( Vector2(2.0, 0.5) )
	tween.tween_property(
		info_panel, "scale", Vector2.ONE, 0.75
	)

func unexplain() -> void:
	info_panel.pivot_offset = Vector2(
		info_panel.size.x / 2.0,
		info_panel.size.y
	)
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		info_panel, "scale", Vector2(1, 0), 0.75
	)

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
