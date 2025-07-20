extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D

@export_category("Jump State")
@export var jump_height : float = -225
@export var jump_horizontal_speed : int = 250
@export var max_jump_horizontal_speed : int = 150
@export var max_jump_count : int = 2
@export var jump_gravity : int = 1000

var current_jump_count : int

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	character_body_2d.velocity.y += jump_gravity * delta
	if character_body_2d.is_on_floor():
		current_jump_count = 0
		character_body_2d.velocity.y = jump_height
		current_jump_count += 1
	
	# Multi Jumps
	if !character_body_2d.is_on_floor() and GameInputEvents.jump_input() and current_jump_count != max_jump_count:
		character_body_2d.velocity.y = jump_height
		current_jump_count += 1
	
	var direction : float = GameInputEvents.movement_input()
	
	if !character_body_2d.is_on_floor():
		character_body_2d.velocity.x += direction * jump_horizontal_speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_jump_horizontal_speed, max_jump_horizontal_speed)
	
	character_body_2d.move_and_slide()
	
	# Idle
	if character_body_2d.is_on_floor():
		transition.emit("Idle")

func enter():
	animated_sprite_2d.play("jump")

func exit():
	animated_sprite_2d.stop()
