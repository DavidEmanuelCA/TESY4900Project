extends Node
class_name HurtState

signal finished()

@export var hurt_animation_name: String = "hurt"
@export var invuln_duration: float = 0.5
@export var sprite_node: NodePath = "AnimatedSprite2D"

var health : Node = null
var sprite : AnimatedSprite2D = null
var _invuln_timer : Timer
var _conn_finished : Callable

func _ready() -> void:
	sprite = get_node_or_null(sprite_node)
	_invuln_timer = Timer.new()
	add_child(_invuln_timer)
	_invuln_timer.one_shot = true
	_invuln_timer.wait_time = invuln_duration
	_invuln_timer.timeout.connect(Callable(self, "_on_invuln_timeout"))
	_conn_finished = Callable(self, "_on_invuln_timeout")

func set_health(h: Node) -> void:
	health = h
	if health and not health.is_connected("health_changed", Callable(self, "_on_health_changed")):
		health.health_changed.connect(Callable(self, "_on_health_changed"))

func enter(owner_node: Node) -> void:
	sprite = owner_node.get_node_or_null(sprite_node) if sprite == null else sprite
	if sprite:
		sprite.play(hurt_animation_name)
	if health:
		health.is_invulnerable = true

func _on_health_changed(current: int, max_health: int) -> void:
	if current <= 0:
		return  # DeathState should handle zero health
	_invuln_timer.start()

func _on_invuln_timeout() -> void:
	if health:
		health.is_invulnerable = false
	emit_signal("finished")

func exit(owner_node: Node) -> void:
	# Ensures clean-up before changing state
	_invuln_timer.stop()
