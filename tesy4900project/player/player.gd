extends CharacterBody2D
class_name PlatformerController2D

@export_category("Nodes")
@export var sprite: AnimatedSprite2D
@export var state_manager: StateManager  # Your combat state manager node

# Movement parameters
@export_range(50.0, 600.0) var max_speed := 200.0
@export_range(0.1, 1.0) var time_to_peak := 0.4
@export_range(0.1, 1.0) var time_to_fall := 0.3
@export_range(20.0, 500.0) var jump_height_px := 100.0
@export var max_jumps := 1
@export var variable_jump := true
@export_range(200.0, 2000.0) var terminal_velocity := 600.0
@export_range(0.0, 0.5) var coyote_time := 0.2
@export_range(0.0, 0.5) var jump_buffer_time := 0.2
@export_range(0.01, 3.0) var accel_time := 0.2

# Internal state
var jump_speed := 0.0
var up_gravity := 0.0
var down_gravity := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var last_time_on_floor := 0
var jump_count := 0
var is_jumping := false
var last_move_dir := 1

@onready var health: Health = $Health

func _ready() -> void:
	# Precompute gravity and jump speeds
	jump_speed = -2.0 * jump_height_px / time_to_peak
	up_gravity = 2.0 * jump_height_px / (time_to_peak * time_to_peak)
	down_gravity = 2.0 * jump_height_px / (time_to_fall * time_to_fall)
	# Initialize StateManager: inject owner and health, switch state AFTER injection
	if state_manager:
		state_manager.init_owner_and_health(self, health) 
	# Connect health signals
	if health:
		health.health_changed.connect(_on_health_changed)
		health.died.connect(_on_player_died)
	else:
		push_error("Player: Health component not found")

func _physics_process(delta: float) -> void:
	# Run state manager updates (combat, hurt, defend, death)
	state_manager._physics_process(delta)
	# Skip movement if in Hurt or Death states
	if state_manager._current and state_manager._current.name in ["Hurt", "Death"]:
		return
	# Handle player-controlled movement
	handle_movement(delta)
	# Hook: Emit "player_defended" if Defend state is active
	if state_manager._current and state_manager._current.name == "Defend":
		Signalbus.emit_signal("player_defended")

# --- Movement Logic ---
func handle_movement(delta: float) -> void:
	process_gravity(delta)
	process_horizontal(delta)
	process_jumping(delta)
	process_animation()
	move_and_slide()

func process_horizontal(delta: float) -> void:
	var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	var target_speed = dir * max_speed
	var accel = abs(target_speed - velocity.x) / accel_time
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	if abs(dir) > 0.1:
		last_move_dir = sign(dir)

func process_gravity(delta: float) -> void:
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	var g = up_gravity if velocity.y < 0 else down_gravity
	velocity.y = min(velocity.y + g * delta, terminal_velocity)

func process_jumping(delta: float) -> void:
	if is_on_floor():
		last_time_on_floor = Time.get_ticks_msec()
		jump_count = 0
		is_jumping = false
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)
	var elapsed = (Time.get_ticks_msec() - last_time_on_floor) / 1000.0
	var can_coyote = elapsed <= coyote_time
	# Jump logic
	if jump_buffer_timer > 0.0 and (can_coyote or jump_count < max_jumps):
		velocity.y = jump_speed
		jump_count += 1
		jump_buffer_timer = 0.0
		is_jumping = true
	# Variable jump cut
	if variable_jump and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

func process_animation() -> void:
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			sprite.speed_scale = abs(velocity.x) / max_speed
			sprite.play("run")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump" if velocity.y < 0 else "fall")
	sprite.flip_h = last_move_dir < 0

# --- Combat and Health Integration ---
func damage(amount: int) -> void:
	health.damage(amount)
	state_manager.switch_to("Hurt")

func _on_health_changed(current: int, max_health: int) -> void:
	Signalbus.emit_signal("player_health_changed", current, max_health)

func _on_player_died() -> void:
	set_physics_process(false)
	state_manager.switch_to("Death")

func _on_hurtbox_body_entered(body: Node2D) -> void:
	# Check if the colliding body is an enemy attack hitbox
	if body.has_meta("is_attack_hitbox"):
		health.damage(body.get("damage") if body.has("damage") else 1)
