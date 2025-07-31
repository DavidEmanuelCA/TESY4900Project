extends Node
class_name RangeAttackState

signal finished(next_state: String)

@export var animation_name: String = "throw"
@export var projectile_scene: PackedScene
@export var projectile_speed: Vector2 = Vector2(400, 0)
@export var attack_duration: float = 0.5
@export var next_state_name: String = "Idle"

var _attack_timer: Timer

func _ready() -> void:
	_attack_timer = Timer.new()
	add_child(_attack_timer)
	_attack_timer.wait_time = attack_duration
	_attack_timer.one_shot = true
	_attack_timer.autostart = false

func _enter(owner: Node) -> void:
	var anim = owner.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play(animation_name)
	if projectile_scene:
		_shoot(owner)
	_attack_timer.start()
	await _attack_timer.timeout
	emit_signal("finished", next_state_name)

func _shoot(owner: Node) -> void:
	var proj = projectile_scene.instantiate()
	var parent_node = owner.get_parent() or owner
	parent_node.add_child(proj)
	proj.global_position = owner.global_position
	if proj.has_variable("velocity"):
		proj.velocity = projectile_speed.rotated(owner.global_rotation if owner.has_method("global_rotation") else 0)
