extends Node
class_name IdleState

signal finished(next_state:String)

@export var idle_animation_name:String = "idle"
@export var sprite_path:NodePath = "AnimatedSprite2D"

func enter(prev_state:String = "", data:Dictionary = {}) -> void:
	# Play idle animation on entering the state
	var owner = self.owner
	if not owner:
		push_error("IdleState.enter(): owner not set")
		return
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play(idle_animation_name)
	else:
		push_warning("IdleState.enter(): sprite not found at " + str(sprite_path))

func physics_update(delta:float) -> void:
	var owner = self.owner
	if not owner:
		return
	# Only apply this animation if the entity is grounded and not moving
	if owner.is_on_floor():
		if owner.has_variable("velocity") and owner.velocity.x != 0:
			# If velocity begins, a RunState (or similar) should handle it,
			# not this state
			return
	else:
		# If in the air, you should fall — not chase or run
		emit_signal("finished", "FallState")

func exit() -> void:
	# Optional: cleanup when leaving state
	pass
