extends CharacterBody2D
class_name Wanderer

@export var damage_amount: int = 1
@export var health_node_path: NodePath = "Health"

@onready var health = get_node_or_null(health_node_path)
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
	else:
		push_error("Wanderer: Health node not found at: " + str(health_node_path))
	state_manager._change_state("IdleState")
	print("Wanderer starting HP:", health.current_health, "/", health.max_health)

func _physics_process(delta: float) -> void:
	state_manager._physics_process(delta)

func damage(amount: int) -> void:
	if not health:
		push_error("Wanderer.damage(): No Health component found")
		return
	health.damage(amount)
	if health.current_health > 0:
		state_manager._change_state("HurtState")

func _on_health_changed(current: int, max_h: int) -> void:
	print("Wanderer hit: now has", current, "/", max_h, "HP")
