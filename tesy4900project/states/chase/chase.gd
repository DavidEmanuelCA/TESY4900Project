extends Node
class_name Chase

signal finished(next_state: String)

@export var chase_speed: float = 120.0
@export var sprite_path: NodePath = "AnimatedSprite2D"
@export var run_animation_name: String = "run"
@export var target_path: NodePath = "../Player" # Can be adjusted per scene

func enter(owner: Node) -> void:
	# Play run animation on entering chase state
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play(run_animation_name)

func physics_update(owner: Node, delta: float) -> void:
	# Ensure the owner is a CharacterBody2D (needed for velocity and move_and_slide)
	if not (owner is CharacterBody2D):
		push_error("Chase.physics_update(): Owner is not a CharacterBody2D")
		return
	var target = owner.get_node_or_null(target_path)
	# If target is valid and in the scene tree, chase it
	if target and target.is_inside_tree():
		var dir = (target.global_position - owner.global_position)
		dir.y = 0  # Ignore vertical axis for horizontal chase
		if dir != Vector2.ZERO:
			dir = dir.normalized()
		owner.velocity.x = dir.x * chase_speed
	else:
		# Stop moving if no valid target
		owner.velocity.x = 0
	# Apply movement
	owner.move_and_slide()

func exit(owner: Node) -> void:
	# Stop movement when leaving chase state
	if owner is CharacterBody2D:
		owner.velocity.x = 0
