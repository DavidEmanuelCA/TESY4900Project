extends Node
class_name IdleState

@export var see_distance: float = 200.0
@export var next_state_name: String = "Chase"

func _enter(owner_node: Node) -> void:
	var anim = owner_node.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play("idle")

func _physics_update(owner_node: Node, delta: float) -> void:
	if not owner_node.has_node("Player"):
		return
	var player = owner_node.get_node("Player")
	if owner_node.global_position.distance_to(player.global_position) <= see_distance:
		owner_node.emit_signal("idle_to_state", next_state_name)
