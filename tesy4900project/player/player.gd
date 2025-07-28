extends CharacterBody2D
class_name PlatformerController2D

@export_category("Nodes")
@export var sprite: AnimatedSprite2D
@export var collider: CollisionShape2D

@export_category("Horizontal Movement")
@export_range(50.0, 600.0) var max_speed := 200.0
@export_range(0.01, 3.0) var accel_time := 0.2
@export_range(0.01, 3.0) var decel_time := 0.2

@export_category("Jump & Gravity")
@export_range(20.0, 500.0) var jump_height_px := 100.0
@export_range(0.1, 1.0) var time_to_peak := 0.4
@export_range(0.1, 1.0) var time_to_fall := 0.3
@export_range(0.0, 0.5) var coyote_time := 0.2
@export_range(0.0, 0.5) var jump_buffer_time := 0.2
@export var max_jumps := 1
@export var variable_jump := true
@export_range(200.0, 2000.0) var terminal_velocity := 600.0

# Internal timers and physics values
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var jump_speed := 0.0
var up_gravity := 0.0
var down_gravity := 0.0
var is_jumping := false
var jump_count := 0
var last_time_on_floor := 0
var last_move_dir := 1  

func _ready():
	jump_speed = -2.0 * jump_height_px / time_to_peak
	up_gravity = 2.0 * jump_height_px / (time_to_peak * time_to_peak)
	down_gravity = 2.0 * jump_height_px / (time_to_fall * time_to_fall)

func _physics_process(delta):
	# timers
	if is_on_floor():
		coyote_timer = coyote_time
		if not is_jumping:
			handle_grounded_animations()
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
		handle_airborne_animations()

	# gravity
	apply_gravity(delta)

	# horizontal
	handle_horizontal_movement(delta)

	# jumping
	handle_jumping(delta)

	move_and_slide()

#func handle_grounded_animations():
	#var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	#if abs(dir) > 0.1:
		#sprite.speed_scale = abs(velocity.x) / max_speed
		#sprite.play("run")
	#else:
		#sprite.play("idle")
	#sprite.flip_h = velocity.x < 0.0

func handle_grounded_animations():
	if abs(velocity.x) > 0.1:
		sprite.speed_scale = abs(velocity.x) / max_speed
		sprite.play("run")
	else:
		sprite.play("idle")
	sprite.flip_h = last_move_dir < 0

func handle_airborne_animations():
	if velocity.y < 0.0:
		sprite.play("jump")
	elif velocity.y > 0.0:
		sprite.play("falling")
	if not is_on_floor() and not is_jumping and Input.is_action_pressed("down"):
		sprite.play("falling")

func apply_gravity(delta):
	if not is_on_floor():
		var g = up_gravity if velocity.y < 0.0 else down_gravity
		velocity.y = min(velocity.y + g * delta, terminal_velocity)

#func handle_horizontal_movement(delta):
	#var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	#var target_speed = dir * max_speed
	#var accel = abs(target_speed - velocity.x) / accel_time
	#velocity.x = move_toward(velocity.x, target_speed, accel * delta)

func handle_horizontal_movement(delta):
	var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	var target_speed = dir * max_speed
	var accel = abs(target_speed - velocity.x) / accel_time
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	
	# Update last_move_dir only when velocity.x is significant
	if abs(velocity.x) > 0.1:
		last_move_dir = sign(velocity.x)

func handle_jumping(delta):
	# 1 — Track when on the ground
	if is_on_floor():
		last_time_on_floor = Time.get_ticks_msec()
		jump_count = 0
		is_jumping = false

	# 2 — Buffer jump input
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	# 3 — Decide if jumping allowed
	var time_since_floor = (Time.get_ticks_msec() - last_time_on_floor) / 1000.0
	var can_coyote_jump = time_since_floor <= coyote_time

	if jump_buffer_timer > 0.0 and (can_coyote_jump or jump_count < max_jumps):
		velocity.y = jump_speed
		jump_count += 1
		jump_buffer_timer = 0.0
		is_jumping = true

	# 4 — Variable jump cut
	if variable_jump and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5
