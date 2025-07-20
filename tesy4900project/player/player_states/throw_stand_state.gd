extends NodeState

var shuriken = preload("res://shuriken.tscn")

@export var character_body_2d : CharacterBody2D
@export var animated_sprite_2d : AnimatedSprite2D
@export var hand : Marker2D
@export var throw_shuriken_time : float = 0.5

var hand_position : Vector2

func on_process(delta : float):
	pass

func on_physics_process(delta : float):
	hand_thow_position()
	
	if GameInputEvents.throw_input():
		throw_shooting()
	
	# Tansition
	
	# Run
	var direction : float = GameInputEvents.movement_input()
	
	if direction and character_body_2d.is_on_floor():
		transition.emit("Run")
	
	# Jump
	if GameInputEvents.jump_input():
		transition.emit("Jump")
	

func enter():
	hand.position = Vector2(17, -15)
	hand_position = hand.position
	
	get_tree().create_timer(throw_shuriken_time).timeout.connect(on_throw_shuriken_timeout)
	animated_sprite_2d.play("throw")

func exit():
	animated_sprite_2d.stop()

func on_throw_shuriken_timeout():
	transition.emit("Idle")

func hand_thow_position():
	if !animated_sprite_2d.flip_h:
		hand.position.x = hand_position.x
	elif animated_sprite_2d.flip_h:
		hand.position.x = -hand_position.x

func throw_shooting():
	var direction : float = -1 if animated_sprite_2d.flip_h == true else 1
	
	var shuriken_instance = shuriken.instantiate() as Node2D
	shuriken_instance.direction = direction
	shuriken_instance.move_x_direction = true
	shuriken_instance.global_position = hand.global_position
	get_parent().add_child(shuriken_instance)
