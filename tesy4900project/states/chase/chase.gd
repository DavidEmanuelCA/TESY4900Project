extends Node
class_name ChaseState

signal finished(next_state:String)

@export var chase_speed: float = 120.0
@export var sprite_path: NodePath = "AnimatedSprite2D"
@export var run_animation_name: String = "run"

var entity: CharacterBody2D
var target: Node2D

func enter(_from:String="", data: Dictionary={}) -> void:
	if data.has("entity") and data["entity"] is CharacterBody2D:
		entity = data["entity"]
	else:
		push_error("ChaseState.enter(): Missing or invalid 'entity' key in data")
	if data.has("target") and data["target"] is Node2D:
		target = data["target"]
	var anim = entity.get_node_or_null(sprite_path)
	if anim:
		anim.play(run_animation_name)

func physics_update(delta: float) -> void:
	if not entity or not entity.is_inside_tree():
		return
	if target and target.is_inside_tree():
		var dir = (target.global_position - entity.global_position)
		dir.y = 0
		if dir != Vector2.ZERO:
			dir = dir.normalized()
		entity.velocity.x = dir.x * chase_speed
	else:
		entity.velocity.x = 0
	entity.move_and_slide()  # Proper way for CharacterBody2D physics :contentReference[oaicite:1]{index=1}

func exit() -> void:
	if entity:
		entity.velocity.x = 0
