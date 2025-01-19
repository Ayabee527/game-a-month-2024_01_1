class_name Player
extends RigidBody2D

const DEFAULT_MAX_HEALTH: int = 15

signal died()
signal point_grabbed(point_color: Color)

@export var default_color: Color = Color.WHITE
@export var move_speed: float = 600.0
@export var max_speed: float = 225.0
@export_range(0.0, 1.0) var camera_lean_amount: float = 0.25

@export_group("Inner Dependencies")
@export var coll_shape: CollisionShape2D
@export var hurt_coll_shape: CollisionShape2D
@export var health: Health
@export var health_indicator: HealthIndicator
@export var sprite: HeightSprite
@export var shadow: Shadow
@export var trail: GPUParticles2D
@export var camera_lean: Marker2D
@export var weapon_handler: WeaponHandler
@export var bleeder: EntityBleeder
@export var draw_control: Marker2D
@export var hurt_sfx: AudioStreamPlayer2D

var color: Color = Color.WHITE

var overheated: bool = false
var dashing: bool = false
var is_invinc: bool = false

var last_ha_milestone: int = 0

func _ready() -> void:
	UpgradeHandler.player = self
	
	color = default_color
	sprite.modulate = default_color
	sprite.hurt_color = Color("e30035")
	grab_camera()
	
	if not RogueHandler.points_updated.is_connected(on_points_updated):
		RogueHandler.points_updated.connect(on_points_updated)
	if not RogueHandler.style_triggered.is_connected(on_style_triggered):
		RogueHandler.style_triggered.connect(on_style_triggered)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		weapon_handler.firing = true
	if Input.is_action_just_released("left_click"):
		weapon_handler.firing = false

func toggle_invinc(invinc: bool) -> void:
	is_invinc = invinc
	hurt_coll_shape.set_deferred("disabled", invinc)

func _process(delta: float) -> void:
	lean_camera()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if not dashing:
		state.linear_velocity = state.linear_velocity.limit_length(max_speed)

func grab_camera() -> void:
	MainCam.target = camera_lean

func lean_camera() -> void:
	var lean_point := (
		((1.0 - camera_lean_amount) * global_position)
		+ (camera_lean_amount * get_global_mouse_position())
	)
	camera_lean.global_position = lean_point

func set_weapons(new_weapons: Array[Weapon]) -> void:
	weapon_handler.weapons = new_weapons

func get_weapons() -> Array[Weapon]:
	return weapon_handler.weapons

func update_health_indicator() -> void:
	health_indicator.update_health(health.health, health.max_health)

func on_points_updated(new_points: int) -> void:
	if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.HEALTHY_AESTHETICS):
		var milestone: int = 500
		var new_ha_milestone = new_points
		if (
			(new_ha_milestone - last_ha_milestone) % milestone >= 0
			and float(new_ha_milestone - last_ha_milestone) / milestone != 0
		):
			var diff_health = floori( float(new_ha_milestone - last_ha_milestone) / milestone )
			prints(last_ha_milestone, new_ha_milestone, diff_health)
			last_ha_milestone = snappedi(new_ha_milestone, milestone)
			
			health.max_health += diff_health
			
			if diff_health > 0:
				RogueHandler.trigger_style(
					global_position, "MAX HEALTH UP!", diff_health
				)
			elif diff_health < 0:
				RogueHandler.trigger_style(
					global_position, "MAX HEALTH DOWN!", diff_health
				)
			
			health_indicator.update_health(health.health, health.max_health)

func on_style_triggered(pos: Vector2, style_name: String, points_inc: int) -> void:
	match style_name:
		"EXPLODED!":
			if UpgradeHandler.upgrade_is_equipped(UpgradeHandler.UPGRADES.DEMOMANIA):
				if randf() <= 0.5:
					health.heal(1)

func get_move_vector() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_up", "move_down")


func _on_hurtbox_hurt(hitbox: Hitbox, damage: int, invinc_time: float) -> void:
	MainCam.shake(25.0, 10.0, 5.0)
	MainCam.hitstop(0.05, 0.75)
	
	health.hurt( roundi( (damage + RogueHandler.hurt_plus) * (1.0 + RogueHandler.hurt_mult) ) )
	bleeder.bleed(damage, 2.0, 40)
	RogueHandler.trigger_style(
		global_position, "[color=dimgray]OW!?[/color]", -floori(RogueHandler.points / 50) - 1
	)
	
	sprite.squish(
		1.0, 5.0, true, false
	)
	hurt_sfx.play()


func _on_hurtbox_knocked_back(knockback: Vector2) -> void:
	apply_central_impulse(knockback)

func _on_weapon_handler_recoiled(recoil: Vector2) -> void:
	apply_central_impulse(recoil)
	sprite.squish(
		0.5, 2.5, true, false
	)


func _on_health_health_changed(new_health: int) -> void:
	update_health_indicator()


func _on_health_was_healed(new_health: int, amount: int) -> void:
	RogueHandler.trigger_style(
		global_position, "[color=green]HEALTH UP![/color]", amount
	)
