extends CharacterBody2D

const GRAVITY = 1000

enum STATE { IDLE, RUN }

var current_state

func _ready():
	current_state = STATE.IDLE

func _physics_process(delta):
	player_falling(delta)
	player_idle(delta)
	
	move_and_slide()

func player_falling(delta):
	if !is_on_floor():
		velocity.y += GRAVITY * delta

func player_idle(delta):
	if is_on_floor():
		current_state = STATE.IDLE
