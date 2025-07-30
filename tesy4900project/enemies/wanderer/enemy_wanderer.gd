extends CharacterBody2D

var wanderer_death_effect = preload("res://enemies/wanderer/wanderer_death_effect.tscn")

@export var PATROL_POINTS : Node
@export var SPEED : int = 1500
@export var WAIT_TIME : int = 3
@export var health_amount : int = 3
@export var damage_amount : int = 1

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer

const GRAVITY = 1000

enum STATE { IDLE, RUN, JUMP }
var CURRENT_STATE : STATE
var direction : Vector2 = Vector2.LEFT
var NUM_OF_POINTS : int
var POINT_POSITIONS : Array[Vector2]
var CURRENT_POINT : Vector2
var CURRENT_POINT_POSITION : int
var CAN_RUN : bool


func _ready():
	if PATROL_POINTS != null :
		NUM_OF_POINTS = PATROL_POINTS.get_children().size()
		for POINT in PATROL_POINTS.get_children():
			POINT_POSITIONS.append(POINT.global_position)
		CURRENT_POINT = POINT_POSITIONS[CURRENT_POINT_POSITION]
	else:
		print("no patrol points")
	
	timer.wait_time = WAIT_TIME
	
	CURRENT_STATE = STATE.IDLE

func _physics_process(delta: float) -> void:
	enemy_gravity(delta)
	enemy_idle(delta)
	enemy_run(delta)
	
	move_and_slide()
	
	enemy_animations()

func enemy_gravity(delta : float):
	velocity.y += GRAVITY * delta

func enemy_idle(delta : float):
	if !CAN_RUN:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
		CURRENT_STATE = STATE.IDLE

func enemy_run(delta : float):
	if !CAN_RUN:
		return
	
	if abs(position.x - CURRENT_POINT.x) > 0.5:
		velocity.x = direction.x * SPEED * delta
		CURRENT_STATE = STATE.RUN
	else:
		CURRENT_POINT_POSITION += 1
		
		if CURRENT_POINT_POSITION >= NUM_OF_POINTS:
			CURRENT_POINT_POSITION = 0
		
		CURRENT_POINT = POINT_POSITIONS[CURRENT_POINT_POSITION]
		
		if CURRENT_POINT.x > position.x:
			direction = Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		
		CAN_RUN = false
		timer.start()
	
	animated_sprite_2d.flip_h = direction.x < 1

func enemy_animations():
	if CURRENT_STATE == STATE.IDLE && !CAN_RUN:
		animated_sprite_2d.play("idle")
	elif CURRENT_STATE == STATE.RUN && CAN_RUN:
		animated_sprite_2d.play("run")

func _on_timer_timeout() -> void:
	CAN_RUN = true

func _on_hurtbod_area_entered(area: Area2D) -> void:
	#print("Hurtbox area entered")
	if area.get_parent().has_method("get_damage_amount"):
		var node = area.get_parent() as Node
		health_amount -= node.damage_amount
		print("Health amount: ", health_amount)
		
		if health_amount <= 0:
			var wanderer_death_effect_instance = wanderer_death_effect.instantiate() as Node2D
			wanderer_death_effect_instance.global_position = global_position
			get_parent().add_child(wanderer_death_effect_instance)
			queue_free()
