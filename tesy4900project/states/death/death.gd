extends Node
class_name Death

@export var death_animation_name: String = "death"
@export var free_delay: float = 0.0

@onready var health = get_parent().get_node("Health")
@export var sprite_node: NodePath
@onready var sprite: AnimatedSprite2D = get_node(sprite_node)
var _waiting_to_free: bool = false

func _ready() -> void:
	if health:
		health.died.connect(Callable(self, "_on_died"))
	else:
		push_error("Death: Health node not found")
	if sprite:
		sprite.animation_finished.connect(Callable(self, "_on_sprite_finished"))
	else:
		push_error("Death: AnimatedSprite2D not found")

func _on_died() -> void:
	print("component triggered")
	if sprite:
		sprite.play(death_animation_name)
		_waiting_to_free = true
	else:
		queue_free()

func _on_sprite_finished() -> void:
	if _waiting_to_free:
		if free_delay > 0.0:
			await get_tree().create_timer(free_delay).timeout
		# Remove the entire entity (player or enemy)
		get_parent().queue_free()
