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
	if not owner:
		return
	# Apply gravity continuously
	if owner is CharacterBody2D:
		owner.velocity.y = min(owner.velocity.y + owner.gravity * delta, owner.terminal_velocity)
		owner.move_and_slide()
	# State transitions
	if owner.is_on_floor():
		if abs(owner.velocity.x) > 0.01:
			finished.emit("Run")
	else:
		finished.emit("Fall")


func exit(owner: Node) -> void:
	pass
