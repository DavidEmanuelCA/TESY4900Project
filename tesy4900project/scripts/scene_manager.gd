extends Node

@export var fade_duration: float = 1.0
@export var scenes: Dictionary = {
	"Level1": "res://levels/level_1.tscn",
	"Level2": "res://levels/level_2.tscn"
}

var _transition_overlay: PackedScene = preload("res://ui/screen_transition/scene_transition_screen.tscn")

func transition_to_scene(level_name: String) -> void:
	var scene_path = scenes.get(level_name)
	if scene_path == null:
		push_error("SceneManager: Invalid level name '%s'" % level_name)
		return
	
	var overlay = _transition_overlay.instantiate()
	get_tree().get_root().add_child(overlay)
	var fade_rect = overlay.get_node_or_null("ColorRect")
	if fade_rect:
		fade_rect.modulate = Color(0, 0, 0, 1)  # fully opaque black
	else:
		push_warning("Overlay: ColorRect node not found; skipping modulate")
	
	await get_tree().create_timer(fade_duration).timeout
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	overlay.queue_free()
