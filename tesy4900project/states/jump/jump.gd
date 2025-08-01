extends Node
class_name JumpState

# Fired when you want to switch to another state
signal finished(next_state:String)

@export var jump_impulse_y: float = 500.0
@export var jump_animation_name: String = "jump"
@export var fall_state_name: String = "FallState"
@export var sprite_path: NodePath = "AnimatedSprite2D"

func enter(prev:String, data:Dictionary={}) -> void:
	var owner = self.owner  # assumes the StateManager sets this property
	if not owner:
		push_error("JumpState.enter(): 'owner' not assigned")
		return
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play(jump_animation_name)
	else:
		push_warning("JumpState: sprite not found at %s" % sprite_path)
	if owner.has_variable("velocity"):
		owner.velocity.y = -abs(jump_impulse_y)
	else:
		push_error("JumpState: owner has no 'velocity' var")

func physics_update(delta:float) -> void:
	var owner = self.owner
	if not owner:
		return
	# Apply gravity if available
	if owner.has_variable("velocity") and owner.has_variable("gravity"):
		owner.velocity.y += owner.gravity * delta
		owner.move_and_slide()
		# Transition to fall once ascending stops
		if owner.velocity.y >= 0:
			emit_signal("finished", fall_state_name)
	else:
		push_error("JumpState: requires owner.velocity and owner.gravity")
		emit_signal("finished", fall_state_name)

func exit() -> void:
	# No explicit cleanup needed here for most flows
	pass
