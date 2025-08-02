extends Node
class_name Fall

signal finished(next_state: String)

@export var fall_animation_name: String = "fall"
@export var sprite_path: NodePath = "AnimatedSprite2D"
@export var idle_state_name: String = "Idle"

func enter(owner: Node) -> void:
	# Play fall animation when entering state
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play(fall_animation_name)
	else:
		push_warning("Fall.enter(): sprite not found at %s" % sprite_path)

func physics_update(owner: Node, delta: float) -> void:
	# Transition to Idle if landed
	if owner.is_on_floor():
		finished.emit(idle_state_name)
		return
	# If still ascending, stay in fall state until downward motion begins
	if owner.velocity.y < 0:
		return
	# Apply gravity and cap at terminal velocity
	if owner.has_variable("gravity") and owner.has_variable("terminal_velocity") and owner.has_variable("velocity"):
		owner.velocity.y = min(owner.velocity.y + owner.gravity * delta, owner.terminal_velocity)
		owner.move_and_slide()
	else:
		push_error("Fall.physics_update(): Owner missing 'velocity', 'gravity', or 'terminal_velocity'")

func exit(owner: Node) -> void:
	# Optional cleanup when leaving fall state
	pass
