extends Node
class_name Run

signal finished(next_state: String)

@export var speed: float = 100.0
@export var stop_distance: float = 10.0
@export var idle_state_name: String = "Idle"
@export var chase_state_name: String = "Chase"
@export var sprite_path: NodePath = "AnimatedSprite2D"
@export var target_path: NodePath = "../Player" # Allows flexible targeting (defaults to sibling named "Player")

func enter(owner: Node) -> void:
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play("run")

func physics_update(owner: Node, delta: float) -> void:
	var target = owner.get_node_or_null(target_path)
	# If target doesn't exist, go back to Idle
	if not target:
		finished.emit(idle_state_name)
		return
	# Move towards the target
	var dir: Vector2 = (target.global_position - owner.global_position).normalized()
	owner.global_position += dir * speed * delta
	# Check distance to switch to chase state
	var dist: float = owner.global_position.distance_to(target.global_position)
	if dist <= stop_distance:
		finished.emit(chase_state_name)

func exit(owner: Node) -> void:
	# Optional: stop movement or reset velocity if needed
	pass
