extends NodeState

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D

@export_category("Run State")
@export var speed : int = 500
@export var max_horizontal_speed : int = 150

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	var direction : float = GameInputEvents.movement_input()
	
	if direction:
		character_body_2d.velocity.x += direction * speed
		character_body_2d.velocity.x = clamp(character_body_2d.velocity.x, -max_horizontal_speed, max_horizontal_speed)
	
	if direction != 0:
		animated_sprite_2d.flip_h = false if direction > 0 else true
	
	character_body_2d.move_and_slide()
	
	# Idle
	if direction == 0:
		transition.emit("Idle")
	
	# Jump
	if direction == 0:
		transition.emit("Jump")
	
	# Fall
	if !character_body_2d.is_on_floor():
		transition.emit("Fall")

func enter():
	animated_sprite_2d.play("run")

func exit():
	animated_sprite_2d.stop()
