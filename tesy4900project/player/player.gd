extends CharacterBody2D
class_name Player

@export_category("Nodes")
@export var sprite: AnimatedSprite2D
@export var health: Health
@export var attack_hitbox_paths: Array[NodePath] = [] # AttackHitbox1, AttackHitbox2, AttackHitbox3
@export var attack_anim_names: Array[String] = ["light1", "light2", "light3"]

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

# Combat settings
@export var attack_damage: int = 1
@export var defend_animation: String = "defend"
@export var hurt_animation: String = "hurt"
@export var death_animation: String = "death"
@export var invuln_duration: float = 0.5

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

var is_defending: bool = false
var is_attacking: bool = false
var is_invulnerable: bool = false
var invuln_timer: float = 0.0

var attack_hitboxes: Array[Area2D] = []

func _ready() -> void:
	# Precompute gravity/jump speeds
	jump_speed = -2.0 * jump_height_px / time_to_peak
	up_gravity = 2.0 * jump_height_px / (time_to_peak * time_to_peak)
	down_gravity = 2.0 * jump_height_px / (time_to_fall * time_to_fall)

	# Cache hitboxes
	for path in attack_hitbox_paths:
		var hb = get_node_or_null(path)
		if hb and hb is Area2D:
			hb.monitoring = false
			hb.set_meta("is_attack_hitbox", true)
			hb.set("damage", attack_damage)
			attack_hitboxes.append(hb)

	# Connect health signals
	if health:
		health.health_changed.connect(_on_health_changed)
		health.died.connect(_on_player_died)
	else:
		push_error("Player: Health node missing!")

func _physics_process(delta: float) -> void:
	# Update invulnerability
	if invuln_timer > 0:
		invuln_timer -= delta
		if invuln_timer <= 0:
			is_invulnerable = false

	if health.current_health <= 0:
		return # Skip updates if dead

	if not is_attacking: 
		handle_input(delta)
		move_and_slide()
	else:
		# Lock movement while attacking
		move_and_slide()

# ---------------- INPUT & MOVEMENT ----------------
func handle_input(delta: float) -> void:
	handle_movement(delta)
	handle_jumping(delta)
	handle_combat()
	handle_animation()

func handle_movement(delta: float) -> void:
	var dir = Input.get_action_strength("right") - Input.get_action_strength("left")
	var target_speed = dir * max_speed
	var accel = abs(target_speed - velocity.x) / accel_time
	velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	if abs(dir) > 0.1:
		last_move_dir = sign(dir)

	# Apply gravity
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
	var g = up_gravity if velocity.y < 0 else down_gravity
	velocity.y = min(velocity.y + g * delta, terminal_velocity)

func handle_jumping(delta: float) -> void:
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
	if jump_buffer_timer > 0.0 and (can_coyote or jump_count < max_jumps):
		velocity.y = jump_speed
		jump_count += 1
		jump_buffer_timer = 0.0
		is_jumping = true
	if variable_jump and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= 0.5

# ---------------- COMBAT ----------------
func handle_combat() -> void:
	# Defend (only if grounded & not attacking)
	if Input.is_action_pressed("defend") and is_on_floor() and not is_attacking:
		if not is_defending:
			start_defend()
	else:
		if is_defending:
			end_defend()

	# Attacks (attack1, attack2, attack3)
	if is_on_floor() and not is_attacking and not is_defending:
		if Input.is_action_just_pressed("attack1"):
			start_attack(0)
		elif Input.is_action_just_pressed("attack2"):
			start_attack(1)
		elif Input.is_action_just_pressed("attack3"):
			start_attack(2)

func start_defend() -> void:
	is_defending = true
	sprite.play(defend_animation)

signal defend_finished

func end_defend() -> void:
	is_defending = false
	defend_finished.emit() # Notify listeners (e.g., enemy AI) that defend just ended


func start_attack(index: int) -> void:
	is_attacking = true
	var hitbox = attack_hitboxes[index]
	if hitbox:
		hitbox.monitoring = true
		hitbox.body_entered.connect(_on_attack_hitbox_body_entered, CONNECT_ONE_SHOT)
	sprite.play(attack_anim_names[index])
	await sprite.animation_finished
	# Disable hitbox after attack finishes
	if hitbox:
		hitbox.monitoring = false
	is_attacking = false

func _on_attack_hitbox_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage(attack_damage)

# ---------------- DAMAGE & DEATH ----------------
func damage(amount: int) -> void:
	if is_invulnerable or is_defending:
		return
	health.damage(amount)
	if health.current_health > 0:
		sprite.play(hurt_animation)
		is_invulnerable = true
		invuln_timer = invuln_duration
	else:
		_on_player_died()

func _on_health_changed(current: int, max_health: int) -> void:
	Signalbus.emit_signal("player_health_changed", current, max_health)

func _on_player_died() -> void:
	sprite.play(death_animation)
	await sprite.animation_finished
	queue_free()

# ---------------- ANIMATION ----------------
func handle_animation() -> void:
	if health.current_health <= 0:
		return
	if is_attacking or is_defending:
		return
	if is_on_floor():
		if abs(velocity.x) > 0.1:
			sprite.play("run")
		else:
			sprite.play("idle")
	else:
		sprite.play("jump" if velocity.y < 0 else "fall")
	sprite.flip_h = last_move_dir < 0

# ---------------- HURTBOX ----------------
func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.has_meta("is_attack_hitbox"):
		health.damage(body.get("damage") if body.has("damage") else 1)
