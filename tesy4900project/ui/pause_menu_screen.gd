extends CanvasLayer


func _on_continue_button_pressed() -> void:
	GameManager.continue_game()
	queue_free()


func _on_main_menu_button_pressed() -> void:
	GameManager.main_menu()
	queue_free()

func _ready():
	get_viewport().size_changed.connect(_on_viewport_resize)
	_on_viewport_resize()

func _on_viewport_resize():
	var screen_size = get_viewport().get_visible_rect().size
	$TextureRect.size = screen_size
