extends Node
class_name StateMachine

@export var initial_state_name: String

var current_state: Node = null
var states: Dictionary = {}

func _ready():
	for child in get_children():
		states[child.name] = child
		if child.has_signal("finished"):
			child.finished.connect(_on_child_finished)
	_change_state(initial_state_name)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state._physics_update(get_parent(), delta)

func _on_child_finished(next_state_name: String) -> void:
	_change_state(next_state_name)

func _change_state(new_name: String) -> void:
	if current_state and current_state.has_method("exit"):
		current_state.exit(get_parent())
	current_state = states.get(new_name)
	if not current_state:
		push_error("State '%s' not found in StateMachine" % new_name)
		return
	if current_state.has_method("enter"):
		current_state.enter(get_parent())
