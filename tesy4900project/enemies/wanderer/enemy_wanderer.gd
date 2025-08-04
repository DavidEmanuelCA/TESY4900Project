extends CharacterBody2D
class_name Wanderer

@export var attack_damage: int = 1
@export var health_node_path: NodePath = "Health"
@export var state_manager_path: NodePath = "StateManager"
@export var enemy_ai_path: NodePath = "EnemyAI"

@onready var health: Health = get_node_or_null(health_node_path)
@onready var state_manager: StateManager = get_node_or_null(state_manager_path)
@onready var enemy_ai: EnemyAI = get_node_or_null(enemy_ai_path)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# Validate and initialize health + state manager
	if not health:
		push_error("Wanderer: Health node not found at path: " + str(health_node_path))
		return
	if not state_manager:
		push_error("Wanderer: StateManager node not found at path: " + str(state_manager_path))
		return
	# Initialize state manager with owner and health
	state_manager.init_owner_and_health(self, health)
	# Connect health signals
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_self_died)
	# Debugging output (can be removed later)
	print("Wanderer starting HP:", health.current_health, "/", health.max_health)

func _physics_process(delta: float) -> void:
	# Update AI behavior and states
	if enemy_ai:
		enemy_ai._physics_process(delta)
	state_manager._physics_process(delta)

# --- Combat ---
func damage(amount: int) -> void:
	if health:
		health.damage(amount)

func on_attack_hit(body: Node) -> void:
	# Called from Wanderer's melee/ranged hitbox Area2D
	if body.has_method("damage"):
		body.damage(attack_damage)

# --- Health Callbacks ---
func _on_health_changed(current: int, max_hp: int) -> void:
	print("Wanderer hit: now has", current, "/", max_hp, "HP")

func _on_self_died() -> void:
	# Switch to death state and disable physics/movement
	set_physics_process(false)
	state_manager.switch_to("Death")
