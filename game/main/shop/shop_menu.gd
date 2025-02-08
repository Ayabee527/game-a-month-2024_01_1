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
@export var roll_label: RichTextLabel
@export var points_label: RichTextLabel
@export var shop_holder: GridContainer
@export var equip_holder: GridContainer
@export var confirm_butt: Button
@export var equips_label: RichTextLabel
@export var info_name: RichTextLabel
@export var info_cost: RichTextLabel
@export var info_desc: RichTextLabel
@export var info_panel: PanelContainer

var new_tier_waiting: bool = false
var tier: int = 1
var max_equips: int = 3
var max_sells: int = 4
var tier_queued: bool = false

var reroll_price: int = 100
var rerolls: int = 0

func _ready() -> void:
	position = Vector2(0, 256)
	await owner.ready
	if not RogueHandler.points_updated.is_connected(update_points):
		RogueHandler.points_updated.connect(update_points)
	if not UpgradeHandler.equips_updated.is_connected(update_equips):
		UpgradeHandler.equips_updated.connect(update_equips)
	
	reload_equips()
	update_equips(UpgradeHandler.equips)

func restock() -> void:
	var possible_upgrades: Array[RogueUpgrade]
	for upgrade: RogueUpgrade in upgrades:
		if upgrade.upgrade_tier <= tier:
			possible_upgrades.append(upgrade)
	
	for child in shop_holder.get_children():
		child.queue_free()
	
	possible_upgrades.shuffle()
	for i: int in max_sells:
		var chosen_upgrade: RogueUpgrade
		chosen_upgrade = possible_upgrades.pop_back()
		if chosen_upgrade in UpgradeHandler.equips:
			continue
		
		if possible_upgrades.is_empty():
			return
		
		var item = SHOP_ITEM.instantiate()
		item.upgrade = chosen_upgrade
		shop_holder.add_child(item)
		item.hovered.connect(explain.bind(chosen_upgrade))
		item.unhovered.connect(unexplain)
		item.confirmed.connect(buy.bind(item))
		await get_tree().create_timer(0.1).timeout

func upgrade_tier() -> void:
	tier += 1
	max_equips = (2 * tier) + 1
	max_sells = tier + 3
	new_tier_waiting = false
	
	tier_label.text = "[wave]TIER " + str(tier)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		tier_label, "scale", Vector2.ONE, 0.75
	).from( Vector2(2, 2) )
	tween.parallel().tween_property(
		tier_label, "modulate", Color.WHITE, 0.75
	).from( Color.GOLD )
	await tween.finished
	
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	equips_label.text = "[wave]EQUIPPED " + str(UpgradeHandler.equips.size()) + "/" + str(max_equips)
	tween.tween_property(
		equips_label, "scale", Vector2.ONE, 0.75
	).from( Vector2(2, 2) )
	tween.parallel().tween_property(
		equips_label, "modulate", Color.WHITE, 0.75
	).from( Color.GOLD )
	await tween.finished
	
	restock()
	confirm_butt.disabled = false

func update_points(new_points: int) -> void:
	points_label.text = "[wave]BITS: " + str(new_points)
	points_label.pivot_offset = points_label.size / 2.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		points_label, "scale", Vector2.ONE, 0.25
	).from( Vector2(1.5, 0.67) )

func update_equips(new_equips: Array[RogueUpgrade]) -> void:
	equips_label.text = "[wave]EQUIPPED " + str(new_equips.size()) + "/" + str(max_equips)
	equips_label.pivot_offset = equips_label.size / 2.0
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.set_parallel()
	tween.tween_property(
		equips_label, "scale", Vector2.ONE, 0.25
	).from( Vector2(1.5, 0.67) )
	tween.tween_property(
		equips_label, "modulate", Color.WHITE, 1.0
	).from(Color.GOLD)
	
	#for child in equip_holder.get_children():
		#child.queue_free()
	
	#for upgrade: RogueUpgrade in new_equips:
		#var item = SHOP_ITEM.instantiate()
		#item.upgrade = upgrade
		#equip_holder.add_child(item)
		#item.hovered.connect(explain.bind(upgrade))
		#item.unhovered.connect(unexplain)
		#item.confirmed.connect(sell.bind(item))

func reload_equips() -> void:
	for child in equip_holder.get_children():
		child.queue_free()
	
	for upgrade: RogueUpgrade in UpgradeHandler.equips:
		var item = SHOP_ITEM.instantiate()
		item.upgrade = upgrade
		equip_holder.add_child(item)
		item.hovered.connect(explain.bind(upgrade))
		item.unhovered.connect(unexplain)
		item.confirmed.connect(sell.bind(item))

func open() -> void:
	unexplain()
	
	if new_tier_waiting:
		for child in shop_holder.get_children():
			child.queue_free()
	else:
		restock()
		confirm_butt.disabled = false
	
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
	if new_tier_waiting:
		upgrade_tier()

func sell(item: ShopItem) -> void:
	RogueHandler.points += item.upgrade.base_price / 2
	UpgradeHandler.equips.erase(item.upgrade)
	UpgradeHandler.equips = UpgradeHandler.equips
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		points_label, "modulate", Color.WHITE, 1.0
	).from(Color.GOLD)
	UpgradeHandler.deactivate_upgrade(item.upgrade.upgrade_id)
	equip_holder.remove_child(item)
	item.queue_free()
	unexplain()

func buy(item: ShopItem) -> void:
	if UpgradeHandler.equips.size() >= max_equips:
		equips_label.pivot_offset = equips_label.size / 2.0
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.set_parallel()
		tween.tween_property(
			equips_label, "scale", Vector2.ONE, 0.25
		).from( Vector2(1.5, 0.67) )
		tween.tween_property(
			equips_label, "modulate", Color.WHITE, 1.0
		).from(Color.RED)
		return
	
	if item.upgrade.base_price <= RogueHandler.points:
		RogueHandler.points -= item.upgrade.base_price
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(
			points_label, "modulate", Color.WHITE, 1.0
		).from(Color.GOLD)
		shop_holder.remove_child(item)
		equip_holder.add_child(item)
		UpgradeHandler.equips.append(item.upgrade)
		UpgradeHandler.equips = UpgradeHandler.equips
		UpgradeHandler.activate_upgrade(item.upgrade.upgrade_id)
		item.bounce()
		item.confirmed.disconnect(buy)
		item.confirmed.connect(sell.bind(item))
		unexplain()
	else:
		RogueHandler.points = RogueHandler.points
		points_label.pivot_offset = points_label.size / 2.0
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		#tween.set_parallel()
		#tween.tween_property(
			#points_label, "scale", Vector2.ONE, 0.25
		#).from( Vector2(1.5, 0.67) )
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
	
	if UpgradeHandler.equips.has(upgrade):
		info_cost.text = "[wave]SELL FOR [color=gold]" + str(upgrade.base_price / 2)
	else:
		info_cost.text = "[wave]BUY FOR [color=gold]" + str(upgrade.base_price)
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
	confirm_butt.disabled = true
	get_tree().paused = false
	normal_music.stream_paused = false
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(
		shop_theme, "volume_db", linear_to_db(0), 2.0
	)
	tween.tween_property(
		normal_music, "pitch_scale", 1.0, 2.0
	)
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUINT)
	tween.tween_property(
		self, "position", Vector2(0, -256), 1.0
	)
	await tween.finished
	shop_theme.playing = false
	hide()
	rerolls = 0
	reroll_price = tier * 100
	roll_label.text = "[wave]REROLL: " + str(reroll_price)
	confirmed.emit()


func _on_reroll_pressed() -> void:
	rerolls += 1
	reroll_price = (tier * 100) * rerolls
	roll_label.text = "[wave]REROLL: " + str(reroll_price)
	if reroll_price <= RogueHandler.points:
		RogueHandler.points -= reroll_price
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(
			points_label, "modulate", Color.WHITE, 1.0
		).from(Color.GOLD)
		restock()
	else:
		RogueHandler.points = RogueHandler.points
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(
			points_label, "modulate", Color.WHITE, 1.0
		).from(Color.RED)
