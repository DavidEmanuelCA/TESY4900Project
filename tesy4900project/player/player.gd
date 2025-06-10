extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const GRAVITY = 1000
@export var SPEED : int = 1000
@export var MAX_HORIZONTAL_SPEED : int = 300
@export var SLOW_DOWN_SPEED : int = 2000
@export var JUMP_HEIGHT : int = -300
@export var JUMP_HORIZONTAL_SPEED : int = 1000
@export var JUMP_MAX_HORIZONTAL_SPEED : int = 300

enum STATE { IDLE, RUN, JUMP }

var current_state : STATE

func _ready():
	current_state = STATE.IDLE

func _physics_process(delta : float):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_jump(delta)
	
	move_and_slide()
	
	player_animations()
	
	print("State: ", STATE.keys()[current_state])

func player_falling(delta : float):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta : float):
	if is_on_floor():
		current_state = STATE.IDLE

func player_run(delta : float):
	if !is_on_floor():
		return
	
	var direction = input_movement()
	
	if direction:
		velocity.x += direction * SPEED * delta
		velocity.x = clamp(velocity.x, -MAX_HORIZONTAL_SPEED, MAX_HORIZONTAL_SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SLOW_DOWN_SPEED * delta)
	
	if direction != 0:
		current_state = STATE.RUN
		animated_sprite_2d.flip_h = false if direction > 0 else true

func player_jump(delta : float):
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_HEIGHT
		current_state = STATE.JUMP
		
	if !is_on_floor() and current_state == STATE.JUMP:
		var direction = input_movement()
		velocity.x += direction * JUMP_HORIZONTAL_SPEED * delta
		velocity.x = clamp(velocity.x, -JUMP_MAX_HORIZONTAL_SPEED, JUMP_MAX_HORIZONTAL_SPEED)

func input_movement():
	var direction: float = Input.get_axis("move_left", "move_right")
	
	return direction

func player_animations():
	if current_state == STATE.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == STATE.RUN:
		animated_sprite_2d.play("run")
	elif current_state == STATE.JUMP:
		animated_sprite_2d.play("jump")
