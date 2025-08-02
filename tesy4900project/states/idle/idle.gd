extends Node
class_name Idle

signal finished(next_state: String)

@export var idle_animation_name: String = "idle"
@export var sprite_path: NodePath = "AnimatedSprite2D"

func enter(owner: Node) -> void:
	# Play idle animation on entering the state
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play(idle_animation_name)
	else:
		push_warning("Idle.enter(): sprite not found at " + str(sprite_path))

func physics_update(owner: Node, delta: float) -> void:
	# Ensure owner is valid and has velocity
	if not owner or not owner.has_variable("velocity"):
		return
	# If entity is on floor and not moving, stay idle
	if owner.is_on_floor():
		if abs(owner.velocity.x) > 0.01:
			# Transition to RunState (or similar) if horizontal movement starts
			finished.emit("RunState")
	else:
		# If off the ground, switch to FallState
		finished.emit("FallState")

func exit(owner: Node) -> void:
	# Optional cleanup when leaving state
	pass
