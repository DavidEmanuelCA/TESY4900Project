extends Node

const MAIN_MENU_SCREEN = preload("res://ui/main_menu_screen.tscn")
const PAUSE_MENU_SCREEN = preload("res://ui/pause_menu_screen.tscn")

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.165,0.184,0.306,1.0))
	
	SettingsManager.load_settings()

func start_game():
	if get_tree().paused:
		continue_game()
		return
	
	SceneManager.transition_to_scene("Level1")

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
