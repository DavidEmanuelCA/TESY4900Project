# Wanderer.gd
extends CharacterBody2D
class_name Wanderer

@export var attack_damage: int = 1
@export var health_node_path: NodePath = "Health"

@onready var health: Health = get_node_or_null(health_node_path)
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_manager: StateManager = $StateManager

func _ready() -> void:
	if not state_manager:
		push_error("Wanderer: StateManager node not found")
		return
	state_manager.set_owner(self)
	if health:
		if state_manager.has_method("set_health"):
			state_manager.set_health(health)
		health.health_changed.connect(Callable(self, "_on_health_changed"))
		health.died.connect(Callable(self, "_on_self_died"))
	else:
		push_error("Wanderer: Health node not found at path: " + str(health_node_path))
	# ensure first draw shows full HP in debug
	print("Wanderer starting HP:", health.current_health, "/", health.max_health)
	state_manager._change_state("IdleState")

func _physics_process(delta: float) -> void:
	state_manager._physics_process(delta)

func damage(amount: int) -> void:
	# if something else bypasses the Hitbox logic
	health.damage(amount)

func _on_health_changed(current: int, max_hp: int) -> void:
	print("Wanderer hit: now has", current, "/", max_hp, "HP")

func _on_self_died() -> void:
	state_manager.set_physics_enabled(false)
	state_manager._change_state("DeathState")

# Called by the hitbox scene when its `body_entered(body)` signal fires
func on_attack_hit(body: Node) -> void:
	if body.has_method("damage"):
		body.damage(attack_damage)
