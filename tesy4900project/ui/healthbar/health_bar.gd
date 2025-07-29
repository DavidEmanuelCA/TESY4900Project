extends Node2D

@export var heart1 : Texture2D
@export var heart0 : Texture2D

@onready var heart_1: Sprite2D = $Heart1
@onready var heart_2: Sprite2D = $Heart2
@onready var heart_3: Sprite2D = $Heart3

@onready var health_component = get_node("path/to/HealthComponent")  # adjust path

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(Callable(self, "on_player_health_changed"))
		# initialize UI
		on_player_health_changed(health_component.current_health, health_component.max_health)
	else:
		push_error("HealthComponent not found for HealthBar UI")

func on_player_health_changed(current: int, max: int) -> void:
	heart_1.texture = heart1 if current >= 1 else heart0
	heart_2.texture = heart1 if current >= 2 else heart0
	heart_3.texture = heart1 if current >= 3 else heart0
	print("HealthBar: updated to", current, "of", max)
