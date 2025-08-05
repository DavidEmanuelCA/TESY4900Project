extends CharacterBody2D
class_name Wanderer

# --- Exported Stats ---
@export var speed: float = 100.0
@export var gravity: float = 900.0
@export var terminal_velocity: float = 600.0

@export var detection_range: float = 200.0
@export var attack_range: float = 50.0

@export var light_attacks: Array[String] = ["attack_light1", "attack_light2", "attack_light3"]
@export var heavy_attack_anim: String = "attack_heavy"
@export var combo_delay: float = 0.4
@export var defend_anim: String = "defend"

# --- Hitboxes ---
@export var attack_hitbox_light1: NodePath
@export var attack_hitbox_light2: NodePath
@export var attack_hitbox_light3: NodePath
@export var attack_hitbox_heavy: NodePath

# --- Patrol ---
@export var patrol_points: Array[NodePath] = []
@export var patrol_pause: float = 1.0
@export var patrol_back_and_forth: bool = true  # NEW: toggle looping or ping-pong

# --- References ---
@export var sprite: AnimatedSprite2D
@export var health_node_path: NodePath = "Health"

@onready var health: Health = get_node_or_null(health_node_path)
@onready var player: Node2D = get_tree().get_first_node_in_group("Player")

# --- Internal ---
var patrol_nodes: Array[Node2D] = []
var patrol_index: int = 0
var patrol_timer: float = 0.0
var patrol_direction: int = 1  # NEW: controls back-and-forth direction

var combo_queue: Array[String] = []
var combo_timer: float = 0.0

var is_attacking: bool = false
var is_defending: bool = false
var is_invulnerable: bool = false
var invuln_timer: float = 0.0
var last_player_defend_time: float = -999.0

func _ready() -> void:
	if not sprite:
		push_error("Wanderer: Missing sprite reference.")
	if not health:
		push_error("Wanderer: Missing health node.")
	# Cache patrol points
	for path in patrol_points:
		var node = get_node_or_null(path)
		if node:
			patrol_nodes.append(node)
		else:
			push_warning("Wanderer: Patrol point not found: " + str(path))
	# Listen for player's defend signal (for punish timing)
	Signalbus.connect("player_defended", Callable(self, "_on_player_defended"))
	print("Wanderer ready. HP:", health.current_health, "/", health.max_health)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y = min(velocity.y + gravity * delta, terminal_velocity)
	else:
		velocity.y = 0
	# Invulnerability timer
	if invuln_timer > 0:
		invuln_timer -= delta
		if invuln_timer <= 0:
			is_invulnerable = false
	# Stop if dead
	if health.current_health <= 0:
		move_and_slide()
		return
	# Combo timer countdown
	if combo_timer > 0:
		combo_timer -= delta
	# AI Behavior
	if not is_attacking and not is_defending:
		if player and player.is_inside_tree():
			var dist = global_position.distance_to(player.global_position)
			# Defend if player close (simple reactive)
			if dist <= attack_range and is_on_floor() and randi() % 100 < 25:
				defend()
			elif dist <= attack_range and is_on_floor():
				decide_attack()
			elif dist <= detection_range:
				chase_player(delta)
			else:
				patrol(delta)
		else:
			patrol(delta)
	move_and_slide()

# --- PATROL ---
func patrol(delta: float) -> void:
	if patrol_nodes.is_empty():
		sprite.play("idle")
		velocity.x = 0
		return
	if patrol_timer > 0:
		patrol_timer -= delta
		sprite.play("idle")
		velocity.x = 0
		return
	var target_point = patrol_nodes[patrol_index]
	if not target_point:
		velocity.x = 0
		return
	# Move toward patrol target
	var dir = (target_point.global_position - global_position).normalized()
	velocity.x = dir.x * speed
	sprite.flip_h = velocity.x < 0
	sprite.play("run")
	# Reached patrol point?
	if global_position.distance_to(target_point.global_position) < 8.0:
		if patrol_back_and_forth:
			# Ping-pong back and forth
			if patrol_index == 0:
				patrol_direction = 1
			elif patrol_index == patrol_nodes.size() - 1:
				patrol_direction = -1
			patrol_index += patrol_direction
		else:
			# Loop
			patrol_index = (patrol_index + 1) % patrol_nodes.size()
		patrol_timer = patrol_pause
		velocity.x = 0  # Stop at patrol point

# --- CHASE PLAYER ---
func chase_player(delta: float) -> void:
	var dir = (player.global_position - global_position).normalized()
	velocity.x = dir.x * speed
	sprite.flip_h = velocity.x < 0
	sprite.play("run")

# --- COMBAT ---
func decide_attack() -> void:
	if Time.get_ticks_msec() / 1000.0 - last_player_defend_time <= 0.4:
		start_attack(heavy_attack_anim, attack_hitbox_heavy)
		return
	if combo_queue.size() > 0 and combo_timer <= 0:
		var next = combo_queue.pop_front()
		var hitbox = _get_hitbox_for_attack(next)
		start_attack(next, hitbox)
		combo_timer = combo_delay
		return
	if randi() % 100 < 70:
		combo_queue = light_attacks.duplicate()
		combo_queue.shuffle()
		var first = combo_queue.pop_front()
		var hitbox = _get_hitbox_for_attack(first)
		start_attack(first, hitbox)
	else:
		start_attack(heavy_attack_anim, attack_hitbox_heavy)

func _get_hitbox_for_attack(attack_name: String) -> NodePath:
	if attack_name == "attack_light1": return attack_hitbox_light1
	elif attack_name == "attack_light2": return attack_hitbox_light2
	elif attack_name == "attack_light3": return attack_hitbox_light3
	return attack_hitbox_heavy

func start_attack(anim_name: String, hitbox_path: NodePath) -> void:
	if not is_on_floor(): return
	is_attacking = true
	sprite.play(anim_name)
	sprite.animation_finished.connect(_on_attack_finished, CONNECT_ONE_SHOT)
	var hb = get_node_or_null(hitbox_path)
	if hb and hb is Area2D:
		hb.set_meta("is_attack_hitbox", true)
		hb.set("damage", 1)
		hb.monitoring = true
		hb.body_entered.connect(_on_hurtbox_body_entered, CONNECT_ONE_SHOT)

func _on_attack_finished(): is_attacking = false
func _on_hurtbox_body_entered(body: Node) -> void:
	if body.has_method("damage") and not is_invulnerable:
		body.damage(1)

# --- DEFEND ---
func defend():
	if is_on_floor() and not is_attacking:
		is_defending = true
		is_invulnerable = true
		sprite.play(defend_anim)
		sprite.animation_finished.connect(_on_defend_finished, CONNECT_ONE_SHOT)

func _on_defend_finished():
	is_defending = false
	is_invulnerable = false

# --- HEALTH ---
func damage(amount: int) -> void:
	if is_invulnerable: return
	health.damage(amount)
	if health.current_health > 0:
		sprite.play("hurt")
		is_invulnerable = true
		invuln_timer = 0.5

func _on_health_changed(current: int, max_hp: int) -> void:
	print("Wanderer HP:", current, "/", max_hp)

func _on_self_died() -> void:
	sprite.play("death")
	await sprite.animation_finished
	queue_free()

# --- SIGNALS ---
func _on_player_defended():
	last_player_defend_time = Time.get_ticks_msec() / 1000.0
