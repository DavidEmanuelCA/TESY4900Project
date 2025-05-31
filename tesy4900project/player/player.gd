extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const GRAVITY = 1000
const SPEED = 300

enum STATE { IDLE, RUN }

var current_state

func _ready():
	current_state = STATE.IDLE

func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	
	move_and_slide()
	
	player_animations()

func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta):
	if is_on_floor():
		current_state = STATE.IDLE
		print("State: ", STATE.keys()[current_state])

func player_run(delta):
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if direction != 0:
		current_state = STATE.RUN
		print("State: ", STATE.keys()[current_state])
		animated_sprite_2d.flip_h = false if direction > 0 else true

func player_animations():
	if current_state == STATE.IDLE:
		animated_sprite_2d.play("idle")
	elif current_state == STATE.RUN:
		animated_sprite_2d.play("run")
