extends CanvasLayer


func _on_continue_button_pressed() -> void:
	GameManager.continue_game()
	queue_free()


func _on_main_menu_button_pressed() -> void:
	GameManager.main_menu()
	queue_free()
