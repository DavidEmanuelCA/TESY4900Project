extends CharacterBody2D
class_name Wanderer

@export var wanderer_death_effect: PackedScene
@export var health_amount: int = 3
@export var damage_amount: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_manager: StateManager = $StateManager

func _ready() -> void:
	# Initialize the state machine and pass self if needed
	if state_manager.has_method("set_owner"):
		state_manager.set_owner(self)
	# Optionally set initial sprite or animations if needed

func _physics_process(delta: float) -> void:
	# Always call state logic
	state_manager._physics_process(delta)

func damage(amount: int) -> void:
	health_amount -= amount
	if health_amount <= 0:
		_on_death()
	else:
		state_manager._change_state("HurtState")

func _on_death() -> void:
	if wanderer_death_effect:
		var effect = wanderer_death_effect.instantiate()
		effect.global_position = global_position
		get_parent().add_child(effect)
	queue_free()
