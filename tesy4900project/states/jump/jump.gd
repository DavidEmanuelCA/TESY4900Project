extends Node
class_name Jump

signal finished(next_state: String)

@export var jump_impulse_y: float = 500.0
@export var jump_animation_name: String = "jump"
@export var fall_state_name: String = "Fall"
@export var sprite_path: NodePath = "AnimatedSprite2D"

func enter(owner: Node) -> void:
	# Play jump animation
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play(jump_animation_name)
	else:
		push_warning("Jump.enter(): sprite not found at %s" % sprite_path)
	# Apply jump impulse
	if owner.has_variable("velocity"):
		owner.velocity.y = -abs(jump_impulse_y)
	else:
		push_error("Jump.enter(): owner has no 'velocity' variable")

func physics_update(owner: Node, delta: float) -> void:
	# Ensure velocity and gravity exist
	if not (owner.has_variable("velocity") and owner.has_variable("gravity")):
		push_error("Jump.physics_update(): requires owner.velocity and owner.gravity")
		finished.emit(fall_state_name)
		return
	# Apply gravity and move
	owner.velocity.y += owner.gravity * delta
	owner.move_and_slide()
	# Transition to Fall when upward motion ends
	if owner.velocity.y >= 0:
		finished.emit(fall_state_name)

func exit(owner: Node) -> void:
	# No cleanup needed for most cases
	pass
