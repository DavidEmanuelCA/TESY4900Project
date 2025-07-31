extends Node
class_name HurtState

signal finished(next_state: String)

@export var hurt_animation_name: String = "hurt"
@export var invuln_duration: float = 0.5

@export var sprite_node: NodePath
@export var next_state_name: String = "IdleState"

var health = null
var sprite: AnimatedSprite2D = null
var _invuln_timer: Timer

func _ready() -> void:
	sprite = get_node_or_null(sprite_node)
	_invuln_timer = Timer.new()
	add_child(_invuln_timer)
	_invuln_timer.one_shot = true
	_invuln_timer.wait_time = invuln_duration
	_invuln_timer.autostart = false
	_invuln_timer.timeout.connect(_on_invuln_timeout)

	if health:
		health.health_changed.connect(Callable(self, "_on_health_changed"))
	else:
		push_error("HurtState: Health not injected")

func set_health(h) -> void:
	health = h

func enter(owner: Node) -> void:
	if sprite:
		sprite.play(hurt_animation_name)

func _on_health_changed(current: int, max_health: int) -> void:
	if current <= 0:
		return  # let Death handle it
	_invuln_timer.start()
	if health:
		health.is_invulnerable = true

func _on_invuln_timeout() -> void:
	if health:
		health.is_invulnerable = false
	emit_signal("finished", next_state_name)
