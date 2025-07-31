extends Node
class_name DeathState

signal finished()

@export var death_animation_name: String = "death"
@export var free_delay: float = 0.0

@export var sprite_node: NodePath

var health = null
var sprite: AnimatedSprite2D = null
var _waiting_to_free = false

func _ready() -> void:
	sprite = get_node_or_null(sprite_node)
	if sprite:
		sprite.animation_finished.connect(_on_sprite_finished)
	if health:
		health.died.connect(Callable(self, "_on_died"))
	else:
		push_error("DeathState: Health not injected")

func set_health(h) -> void:
	health = h

func enter(owner: Node) -> void:
	if sprite:
		sprite.play(death_animation_name)
		_waiting_to_free = true
	else:
		owner.queue_free()

func _on_died() -> void:
	# optional: could trigger UI or effects
	pass

func _on_sprite_finished(anim_name: String) -> void:
	if _waiting_to_free:
		if free_delay > 0.0:
			await get_tree().create_timer(free_delay).timeout
		get_parent().queue_free()
		emit_signal("finished")
