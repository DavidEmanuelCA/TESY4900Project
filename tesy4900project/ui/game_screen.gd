extends CanvasLayer

@onready var collectible_label: Label = $MarginContainer/VBoxContainer/HBoxContainer/CollectibleLabel

func _ready() -> void:
	CollectibleManager.on_collectible_award_recieved.connect(on_collectible_award_recieved)
	

func on_collectible_award_recieved(total_award : int):
	collectible_label.text = str(total_award)
