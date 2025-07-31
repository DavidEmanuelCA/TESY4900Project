extends Node
class_name ChaseState

@export var speed: float = 120.0
@export var target_node_path: NodePath = "Player"
@export var attack_distance: float = 30.0
@export var idle_state_name: String = "Idle"
@export var attack_state_name: String = "Attack"

func _enter(owner_node: Node) -> void:
	var anim = owner_node.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("run")

func _physics_update(owner_node: Node, delta: float) -> void:
	var target = owner_node.get_node_or_null(target_node_path)
	if not target:
		emit_signal("finished", idle_state_name)
		return
	var direction = (target.global_position - owner_node.global_position).normalized()
	owner_node.position += direction * speed * delta
	var dist = owner_node.global_position.distance_to(target.global_position)
	if dist <= attack_distance:
		emit_signal("finished", attack_state_name)
