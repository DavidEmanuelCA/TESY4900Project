extends Node

var scenes : Dictionary = { "Level1": "res://levels/level_1.tscn",
							"Level2": "res://levels/level_2.tscn" }

var scene_transition_screen = preload("res://ui/screen_transition/scene_transition_screen.tscn")

func transition_to_scene(level: String):
	var scene_path = scenes.get(level)
	if not scene_path:
		push_error("Invalid level name: %s" % level)
		return
	var trans = scene_transition_screen.instantiate()
	get_tree().get_root().add_child(trans)
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	trans.queue_free()
