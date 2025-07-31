extends Node
class_name JumpState

@export var jump_speed: Vector2 = Vector2(0, -300.0)
@export var gravity: float = 800.0
@export var land_state_name: String = "Idle"

func _enter(owner_node: Node) -> void:
	# Play jump animation if available
	var anim = owner_node.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("jump")
	# Set initial vertical velocity if owner has one
	if owner_node.has_variable("velocity"):
		owner_node.velocity = Vector2(owner_node.velocity.x, jump_speed.y)
	owner_node.set_physics_process(true)

func _physics_update(owner_node: Node, delta: float) -> void:
	# Apply gravity manually if owner has velocity
	if owner_node.has_variable("velocity"):
		owner_node.velocity.y += gravity * delta
		owner_node.move_and_slide()
		# When vertical velocity becomes positive (descending) and is on floor — land
		if owner_node.velocity.y > 0 and owner_node.is_on_floor():
			emit_signal("finished", land_state_name)
	else:
		emit_signal("finished", land_state_name)
