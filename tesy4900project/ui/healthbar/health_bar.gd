extends Node2D
class_name HealthBar

@export var full_heart: Texture2D
@export var empty_heart: Texture2D
@export var heart_spacing: int = 22
@export var start_position: Vector2 = Vector2(14, 12) # First heart position
@export var heart_scene: PackedScene # Optional: Allows custom heart scene if needed (else uses Sprite2D)

var hearts: Array[Sprite2D] = []
var current_max: int = 0

func _ready() -> void:
	Signalbus.connect("player_health_changed", _on_health_changed)

func _on_health_changed(current: int, max_health: int) -> void:
	# If max health changed, regenerate heart sprites
	if max_health != current_max:
		_generate_hearts(max_health)
		current_max = max_health
	# Update hearts textures based on current health
	for i in range(hearts.size()):
		hearts[i].texture = full_heart if i < current else empty_heart
	print("HealthBar: updated to", current, "of", max_health)

func _generate_hearts(max_health: int) -> void:
	# Clear existing hearts
	for heart in hearts:
		heart.queue_free()
	hearts.clear()
	# Generate new hearts dynamically
	for i in range(max_health):
		var heart: Sprite2D
		if heart_scene:
			heart = heart_scene.instantiate()
		else:
			heart = Sprite2D.new()
			heart.texture = empty_heart
		add_child(heart)
		# Position each heart: start_position + (spacing * index)
		heart.position = Vector2(start_position.x + (i * heart_spacing), start_position.y)
		hearts.append(heart)
