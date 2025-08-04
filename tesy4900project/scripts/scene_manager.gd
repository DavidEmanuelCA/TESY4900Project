extends Node

@export var fade_duration: float = 1.0
@export var scenes: Dictionary = {
	"Level1": "res://levels/level_1.tscn",
	"Level2": "res://levels/level_2.tscn"
}

var _transition_overlay: PackedScene = preload("res://ui/screen_transition/scene_transition_screen.tscn")
var _is_transitioning: bool = false

func transition_to_scene(level_name: String) -> void:
	if _is_transitioning:
		return # Prevent multiple transitions at once
	_is_transitioning = true
	var scene_path: String = scenes.get(level_name, "")
	if scene_path.is_empty():
		push_error("SceneManager: Invalid level name '%s'" % level_name)
		_is_transitioning = false
		return
	# Create overlay and fade in
	var overlay := _transition_overlay.instantiate()
	get_tree().root.add_child(overlay)
	var fade_rect: ColorRect = overlay.get_node_or_null("ColorRect")
	if fade_rect:
		fade_rect.modulate = Color(0, 0, 0, 0) # Start transparent
		var tween := create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, fade_duration)
	else:
		push_warning("SceneManager: ColorRect not found in transition overlay!")
	await get_tree().create_timer(fade_duration).timeout
	# Change scene
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	# Fade back out
	if fade_rect:
		var tween := create_tween()
		tween.tween_property(fade_rect, "modulate:a", 0.0, fade_duration)
		await get_tree().create_timer(fade_duration).timeout
	overlay.queue_free()
	_is_transitioning = false


func reload_current_scene() -> void:
	# Reloads the active scene (e.g., after death or reset)
	var current_scene = get_tree().current_scene
	if current_scene:
		transition_to_scene(current_scene.name)

func start_game() -> void:
	# Shortcut for starting the game (e.g., Level1 by default)
	transition_to_scene("Level1")
