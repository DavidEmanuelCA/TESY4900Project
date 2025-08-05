extends Node

var settings_data: SettingsDataResource

var save_settings_path = "user://game_data/"
var save_file_name = "settings_data.tres"

func load_settings():
	if !DirAccess.dir_exists_absolute(save_settings_path):
		DirAccess.make_dir_absolute(save_settings_path)
	if ResourceLoader.exists(save_settings_path + save_file_name):
		settings_data = ResourceLoader.load(save_settings_path + save_file_name)
	if settings_data == null:
		settings_data = SettingsDataResource.new()
	# Apply saved settings
	set_window_mode(settings_data.window_mode, settings_data.window_mode_index)
	set_resolution(settings_data.resolution, settings_data.resolution_index)

func set_window_mode(window_mode: int, window_mode_index: int):
	match window_mode:
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			var display_size = DisplayServer.screen_get_size() # Native resolution
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_size(display_size)
			# Enforce 16:9 with black bars
			get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
			get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		DisplayServer.WINDOW_MODE_MAXIMIZED:
			var display_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_size(display_size)
			DisplayServer.window_set_position(Vector2i(0, 0))
		DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	settings_data.window_mode = window_mode
	settings_data.window_mode_index = window_mode_index

func set_resolution(resolution: Vector2i, resolution_index: int):
	# Only affects windowed modes
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_size(resolution)
		var screen_size = DisplayServer.screen_get_size()
		var pos = (screen_size - resolution) / 2
		DisplayServer.window_set_position(pos)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED: # Borderless fills screen
		DisplayServer.window_set_size(DisplayServer.screen_get_size())
	settings_data.resolution = resolution
	settings_data.resolution_index = resolution_index
	# Force camera zoom recalculation after resolution change
	for camera in get_tree().get_nodes_in_group("Cameras"):
		camera._adjust_zoom()


func get_settings() -> SettingsDataResource:
	return settings_data

func save_settings():
	ResourceSaver.save(settings_data, save_settings_path + save_file_name)
