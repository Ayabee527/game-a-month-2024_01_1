class_name LaserAttack
extends Node2D

@export var length: float = 1024

@export_group("Data")
@export var collision_data: CollisionData
@export var attack_data: LaserData

@export_group("Inner Dependencies")
@export var hitbox: Hitbox
@export var hitbox_collision: CollisionShape2D

var cur_track_speed: float = 0.0
var cur_track_accel_time: float = 0.0

var velocity: Vector2 = Vector2.ZERO
var target: Node2D

var color: Color = Color.RED
var draw_width: float = 0.0

var warning: bool = false

func _ready() -> void:
	color = attack_data.color
	
	hitbox.damage = attack_data.hitbox_data.damage
	hitbox.trigger_invinc = attack_data.hitbox_data.trigger_invinc
	hitbox.damage_cooldown = attack_data.hitbox_data.damage_cooldown
	hitbox.knockback_strength = attack_data.hitbox_data.knockback_strength
	hitbox.status_effect = attack_data.hitbox_data.status_effect
	hitbox.status_effect_ticks = attack_data.hitbox_data.status_effect_ticks
	
	var col_shape = RectangleShape2D.new()
	col_shape.size = Vector2(length, attack_data.width)
	hitbox_collision.shape = col_shape
	hitbox_collision.position = Vector2(length / 2.0, 0)
	
	hitbox.collision_layer = collision_data.collision_layer
	hitbox.collision_mask = collision_data.collision_mask
	
	cur_track_speed = attack_data.start_track_speed
	length = attack_data.length
	
	if attack_data.warn_time > 0.0:
		warn()
	else:
		fire()
	await get_tree().process_frame
	find_target()

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if warning:
		var warn_color: Color = color
		warn_color.a = 0.25
		draw_circle(
			Vector2.ZERO,
			draw_width + 4.0,
			warn_color, true
		)
		draw_line(
			Vector2.ZERO, Vector2.RIGHT * length, warn_color, draw_width + 2.0
		)
	else:
		draw_circle(
			Vector2.ZERO,
			draw_width + 4.0,
			color, false, 1.0
		)
		draw_line(
			Vector2.ZERO, Vector2.RIGHT * length, color, draw_width + 2.0
		)
		
		draw_circle(
			Vector2.ZERO,
			draw_width + 0.0,
			Color.WHITE, true, 
		)
		draw_line(
			Vector2.ZERO, Vector2.RIGHT * length, Color.WHITE,
			draw_width
		)

func _physics_process(delta: float) -> void:
	if is_instance_valid(target) and attack_data.homes:
		home_on_target(delta)
	else:
		global_rotation_degrees += attack_data.turn_speed * delta
	
	if attack_data.track_accel_time > 0.0:
		cur_track_speed = lerpf(
			attack_data.start_track_speed, attack_data.end_track_speed,
			cur_track_accel_time / abs(attack_data.track_accel_time)
		)
	if cur_track_accel_time < attack_data.track_accel_time:
		cur_track_accel_time += delta
		cur_track_accel_time = min(cur_track_accel_time, abs(attack_data.track_accel_time))

func warn() -> void:
	warning = true
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(
		self, "draw_width", attack_data.width, attack_data.warn_time
	).from(0.0)
	await tween.finished
	warning = false
	fire()

func fire() -> void:
	hitbox_collision.set_deferred("disabled", false)
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(
		self, "draw_width", attack_data.width, 0.25
	).from(0.0)
	await get_tree().create_timer(attack_data.sustain_time, false).timeout
	fade()

func fade() -> void:
	hitbox_collision.set_deferred("disabled", true)
	var tween := create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	#tween.tween_property(
		#self, "modulate:a", 0.0, attack_data.fade_time
	#)
	tween.tween_property(
		self, "draw_width", 0.0, attack_data.fade_time
	)
	await tween.finished
	attack_data.expired.emit()
	queue_free()

func home_on_target(delta: float) -> void:
	var dir_to_target: Vector2 = global_position.direction_to(target.global_position)
	var angle_to: float = Vector2.from_angle(global_rotation).angle_to(dir_to_target)
	if angle_to <= cur_track_speed:
		global_rotation_degrees += cur_track_speed * sign(angle_to) * delta

func find_target() -> void:
	if not is_inside_tree():
		return
	
	if not get_tree():
		return
	
	var targets: Array[Node2D] = []
	for group in attack_data.targets:
		targets.append_array(get_tree().get_nodes_in_group(group))
	var closest_dist: float = INF
	var closest_target: Node2D = null
	for c_target: Node2D in targets:
		var dist_to: float = global_position.distance_squared_to(c_target.global_position)
		if dist_to < closest_dist:
			closest_dist = dist_to
			closest_target = c_target
	
	target = closest_target
	if target != null:
		if target.has_signal("died") and not target.is_connected("died", find_target):
			target.died.connect(find_target)
		else:
			if not target.is_connected("tree_exited", find_target):
				target.tree_exited.connect(find_target)
	else:
		await get_tree().create_timer(0.25, false).timeout
		find_target()
