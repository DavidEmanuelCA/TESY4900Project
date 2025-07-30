extends Node
class_name Hurt

@export var hurt_animation_name: String = "hurt"
@export var invuln_duration: float = 0.0

@onready var health = get_parent().get_node("Health")
@export var sprite_node: NodePath
@onready var sprite: AnimatedSprite2D = get_node(sprite_node)
@onready var invuln_timer = Timer.new()

func _ready() -> void:
	if invuln_duration > 0:
		add_child(invuln_timer)
		invuln_timer.one_shot = true
		invuln_timer.wait_time = invuln_duration
		invuln_timer.autostart = false
		invuln_timer.timeout.connect(_on_invuln_timeout)
		if health:
			health.health_changed.connect(Callable(self, "_on_health_changed"))
		else:
			push_error("Hurt: cannot find Health node")

func _on_health_changed(current: int, max_health: int) -> void:
	print("hurt component saw health: ", current)
	if current <= 0:
		return  # let Death handle end-state
	if sprite:
		sprite.play(hurt_animation_name)
	if invuln_duration > 0 and not invuln_timer.is_stopped():
		invuln_timer.start()
		health.is_invulnerable = true

func _on_invuln_timeout() -> void:
	health.is_invulnerable = false
