extends Node
class_name RunState

@export var speed: float = 100.0
@export var stop_distance: float = 10.0
@export var idle_state_name: String = "Idle"
@export var chase_state_name: String = "Chase"

func _enter(owner_node: Node) -> void:
	var anim = owner_node.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("run")

func _physics_update(owner_node: Node, delta: float) -> void:
	var target = owner_node.get_node_or_null("Player")
	if not target:
		emit_signal("finished", idle_state_name)
		return
	var dir = (target.global_position - owner_node.global_position).normalized()
	owner_node.position += dir * speed * delta
	var dist = owner_node.global_position.distance_to(target.global_position)
	if dist <= stop_distance:
		emit_signal("finished", chase_state_name)
