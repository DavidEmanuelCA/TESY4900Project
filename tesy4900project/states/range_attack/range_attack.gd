extends Node
class_name RangeAttack

signal finished(next_state: String)

@export var animation_name: String = "throw"
@export var projectile_scene: PackedScene
@export var projectile_speed: Vector2 = Vector2(400, 0)
@export var attack_duration: float = 0.5
@export var next_state_name: String = "Idle"
@export var sprite_path: NodePath = "AnimatedSprite2D"

var _attack_timer: Timer

func _ready() -> void:
	# Create a dedicated timer for attack duration
	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.autostart = false
	add_child(_attack_timer)

func enter(owner: Node) -> void:
	# Play throw animation
	var anim = owner.get_node_or_null(sprite_path)
	if anim:
		anim.play(animation_name)
	# Fire projectile if defined
	if projectile_scene:
		_shoot(owner)
	# Start attack timer, then return to next state
	_attack_timer.wait_time = attack_duration
	_attack_timer.start()
	_attack_timer.timeout.connect(
		func():
			finished.emit(next_state_name),
		Object.CONNECT_ONE_SHOT
	)

func physics_update(owner: Node, delta: float) -> void:
	# Typically no physics updates during ranged attack
	pass

func exit(owner: Node) -> void:
	# Stop timer if state exits early
	if _attack_timer and _attack_timer.is_stopped() == false:
		_attack_timer.stop()

# --- Internal Helper ---
func _shoot(owner: Node) -> void:
	var proj = projectile_scene.instantiate()
	var parent_node = owner.get_parent() or owner
	parent_node.add_child(proj)
	proj.global_position = owner.global_position
	# Assign velocity if the projectile supports it
	if proj.has_variable("velocity"):
		var rotation_angle: float = owner.global_rotation if owner.has_method("global_rotation") else 0
		proj.velocity = projectile_speed.rotated(rotation_angle)
