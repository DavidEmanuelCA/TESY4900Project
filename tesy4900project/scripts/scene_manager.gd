extends Node

var scenes : Dictionary = { "Level1": "res://levels/level_1.tscn",
							"Level2": "res://levels/level_2.tscn" }

var scene_transition_screen = preload("res://ui/screen_transition/scene_transition_screen.tscn")

#func transition_to_scene(level : String):
	#var scene_path : String = scenes.get(level)
	
	#if scene_path != null:
		#var scene_transition_screen_instance = scene_transition_screen.instantiate()
		#get_tree().get_root().add_child(scene_transition_screen_instance)
		#await get_tree().create_timer(1.0).timeout
		#get_tree().change_scene_to_file(scene_path)
		#scene_transition_screen_instance.queue_free()

func transition_to_scene(level: String):
	var scene_path = scenes.get(level)
	if scene_path:
		var trans = scene_transition_screen.instantiate()
		get_tree().get_root().add_child(trans)
		# Fade in (black screen appears)
		await get_tree().create_timer(1.0).timeout
		# Change scene (instant swap in Godot 4)
		get_tree().change_scene_to_file(scene_path)
		# Allow one frame for the new scene to initialize before removing the overlay
		await get_tree().process_frame
		# Remove the transition screen (black overlay)
		trans.queue_free()
