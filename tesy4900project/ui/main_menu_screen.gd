extends CanvasLayer


func _on_play_button_pressed() -> void:
	GameManager.start_game()
	
	queue_free()


func _on_exit_button_pressed() -> void:
	GameManager.exit_game()
