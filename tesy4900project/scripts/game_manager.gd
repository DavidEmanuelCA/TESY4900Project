extends Node

const MAIN_MENU_SCREEN = preload("res://ui/main_menu_screen.tscn")
const PAUSE_MENU_SCREEN = preload("res://ui/pause_menu_screen.tscn")
const LEVEL_1 = preload("res://levels/level_1.tscn")

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.16,0.18,0.30,1.00))

func start_game():
	if get_tree().paused:
		continue_game()
		return
	
	transtition_to_scene(LEVEL_1.resource_path)

func exit_game():
	get_tree().quit()

func pause_game():
	get_tree().paused = true
	
	var PAUSE_MENU_SCREEN_INSTANCE = PAUSE_MENU_SCREEN.instantiate()
	get_tree().get_root().add_child(PAUSE_MENU_SCREEN_INSTANCE)

func continue_game():
	get_tree().paused = false

func main_menu():
	var MAIN_MENU_SCREEN_INSTANCE = MAIN_MENU_SCREEN.instantiate()
	get_tree().get_root().add_child(MAIN_MENU_SCREEN_INSTANCE)

func transtition_to_scene(scene_path):
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_path)
