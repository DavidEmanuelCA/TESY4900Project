extends CanvasLayer

func _ready() -> void:
	_adjust_ui_scale()
	get_viewport().size_changed.connect(_adjust_ui_scale)

func _adjust_ui_scale() -> void:
	var base_res = Vector2(2560, 1440)
	var current_res = get_viewport().get_visible_rect().size
	var ui_scale = current_res.y / base_res.y  # Scale relative to vertical res
	# Scale the first child container of the CanvasLayer (your UI root)
	if get_child_count() > 0:
		var ui_root = get_child(0)  # Assuming the MarginContainer is the first child
		ui_root.scale = Vector2(ui_scale, ui_scale)


func _on_pause_texture_button_pressed() -> void:
	GameManager.pause_game()
