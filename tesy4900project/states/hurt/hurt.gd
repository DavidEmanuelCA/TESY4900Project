extends Node
class_name Hurt

signal finished(next_state: String)

@export var hurt_animation_name: String = "hurt"
@export var invuln_duration: float = 0.5
@export var sprite_path: NodePath = "AnimatedSprite2D"
@export var next_state_name: String = "Idle"

var _sprite: AnimatedSprite2D
var _invuln_timer: Timer
var _health: Node

func _ready() -> void:
	# Setup invulnerability timer
	_invuln_timer = Timer.new()
	_invuln_timer.one_shot = true
	_invuln_timer.wait_time = invuln_duration
	add_child(_invuln_timer)
	_invuln_timer.timeout.connect(_on_invuln_timeout)

func enter(owner: Node) -> void:
	# Fetch health node via state manager's injected reference
	_health = get_parent().injected_health if get_parent().has_variable("injected_health") else null
	# Play hurt animation if sprite is valid
	_sprite = owner.get_node_or_null(sprite_path)
	if _sprite:
		_sprite.play(hurt_animation_name)
	# Enable invulnerability
	if _health:
		_health.is_invulnerable = true
	# Connect to health_changed signal if not already connected
	if _health and not _health.health_changed.is_connected(_on_health_changed):
		_health.health_changed.connect(_on_health_changed)

func physics_update(owner: Node, delta: float) -> void:
	# Hurt state is usually passive; leave empty unless extra behavior is needed
	pass

func exit(owner: Node) -> void:
	# Stop invuln timer and ensure cleanup
	_invuln_timer.stop()
	if _health:
		_health.health_changed.disconnect(_on_health_changed)

# --- Internal Signal Callbacks ---
func _on_health_changed(current: int, max_health: int) -> void:
	# If health reaches 0, Death state should handle it
	if current <= 0:
		return
	# Start invulnerability window timer
	_invuln_timer.start()

func _on_invuln_timeout() -> void:
	# End invulnerability and finish
	if _health:
		_health.is_invulnerable = false
	finished.emit(next_state_name)
