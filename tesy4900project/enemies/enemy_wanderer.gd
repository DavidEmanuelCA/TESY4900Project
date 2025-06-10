extends CharacterBody2D

@export var PATROL_POINTS : Node

const GRAVITY = 1000
const SPEED = 1500

enum STATE { IDLE, RUNNING, JUMPING }
var CURRENT_STATE : STATE
var direction : Vector2 = Vector2.LEFT
var NUM_OF_POINTS : int
var POINT_POSITIONS : Array[Vector2]
var CURRENT_POINT : Vector2
var CURRENT_POINT_POSITION : int

func _ready():
	if PATROL_POINTS != null :
		NUM_OF_POINTS = PATROL_POINTS.get_children().size()
		for POINT in PATROL_POINTS.get_children():
			POINT_POSITIONS.append(POINT.global_position)
		CURRENT_POINT = POINT_POSITIONS[CURRENT_POINT_POSITION]
	else:
		print("no patrol points")
	
	CURRENT_STATE = STATE.IDLE
	

func _physics_process(delta: float) -> void:
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_run(delta)
	
	move_and_slide()

func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta : float):
	velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	CURRENT_STATE = STATE.IDLE

func enemy_run(delta : float):
	velocity.x = direction.x * SPEED * delta
	CURRENT_STATE = STATE.RUNNING
