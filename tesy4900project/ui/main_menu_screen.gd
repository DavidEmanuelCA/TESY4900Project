extends CanvasLayer

const SETTINGS_MENU_SCREEN = preload("res://ui/settings_menu_screen.tscn")

func _on_play_button_pressed() -> void:
	GameManager.start_game()
	
	queue_free()


func _on_exit_button_pressed() -> void:
	GameManager.exit_game()


func _on_settings_button_pressed() -> void:
	var settings_menu_screen_instance = SETTINGS_MENU_SCREEN.instantiate()
	get_tree().get_root().add_child(settings_menu_screen_instance)

func _ready():
	get_viewport().size_changed.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize():
	var screen_size = get_viewport().get_visible_rect().size
	$TextureRect.size = screen_size
