extends Node2D

@export var heart1 : Texture2D
@export var heart0 : Texture2D

@onready var heart_1: Sprite2D = $Heart1
@onready var heart_2: Sprite2D = $Heart2
@onready var heart_3: Sprite2D = $Heart3

func _ready():
	Signalbus.connect("player_health_changed", Callable(self, "on_health_changed"))
	#print("HealthBar update: ", current, max_health)

func on_health_changed(current: int, max_health: int) -> void:
	heart_1.texture = heart1 if current >= 1 else heart0
	heart_2.texture = heart1 if current >= 2 else heart0
	heart_3.texture = heart1 if current >= 3 else heart0
	print("HealthBar: updated to", current, "of", max)
