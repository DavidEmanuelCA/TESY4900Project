extends Node
class_name Death

signal finished(next_state: String)

@export var death_animation_name: String = "death"
@export var free_delay: float = 0.0
@export var sprite_path: NodePath = "AnimatedSprite2D"

var _sprite: AnimatedSprite2D
var _health: Node
var _waiting_to_free: bool = false

func enter(owner: Node) -> void:
	# Get injected health from state manager
	_health = get_parent().injected_health if get_parent().has_variable("injected_health") else null
	if not _health:
		push_error("Death.enter(): No health node injected")
	# Play death animation if sprite exists
	_sprite = owner.get_node_or_null(sprite_path)
	if _sprite:
		if not _sprite.animation_finished.is_connected(_on_sprite_finished):
			_sprite.animation_finished.connect(_on_sprite_finished)
		_sprite.play(death_animation_name)
		_waiting_to_free = true
	else:
		# No sprite? Free owner immediately
		owner.queue_free()
	# Connect to died signal (optional, for effects/UI triggers)
	if _health and not _health.died.is_connected(_on_died):
		_health.died.connect(_on_died)

func physics_update(owner: Node, delta: float) -> void:
	# Death state is passive; no physics logic
	pass

func exit(owner: Node) -> void:
	# Cleanup connections if state changes unexpectedly (rare for death)
	if _sprite and _sprite.animation_finished.is_connected(_on_sprite_finished):
		_sprite.animation_finished.disconnect(_on_sprite_finished)
	if _health and _health.died.is_connected(_on_died):
		_health.died.disconnect(_on_died)

# --- Internal Signal Callbacks ---
func _on_died() -> void:
	# Optional: could trigger effects, UI updates, etc.
	pass

func _on_sprite_finished(anim_name: String) -> void:
	if anim_name == death_animation_name and _waiting_to_free:
		_waiting_to_free = false
		# Optional delay before freeing
		if free_delay > 0.0:
			await get_tree().create_timer(free_delay).timeout
		# Free the entity's parent (the root of the enemy/player node)
		get_parent().queue_free()
		finished.emit("") # Death usually doesn't transition to another state
