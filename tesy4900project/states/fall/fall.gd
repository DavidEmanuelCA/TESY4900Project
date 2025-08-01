# res://states/fall/FallState.gd
extends Node
class_name FallState

signal finished(next_state: String)

@export var fall_animation_name: String = "fall"

func enter(previous: String = "", data := {}) -> void:
	# Immediately speed up exit from JumpState then fall
	data.owner.sprite.play(fall_animation_name)

func physics_update(owner, delta: float) -> void:
	if owner.is_on_floor():
		emit_signal("finished", "IdleState")
		return
	if owner.velocity.y < 0:
		# Still moving upward from jump; postpone "fall"
		return
	# Apply gravity (owner exposes this property)
	owner.velocity.y = min(owner.velocity.y + owner.gravity * delta, owner.terminal_velocity)
	owner.move_and_slide()

func exit() -> void:
	# No specific cleanup needed, but available if needed
	pass
