extends Node
class_name SimpleStateManager  # optional, remove if duplicate

@export var initial_state_name: String = ""

var current_state: Node = null
var states: Dictionary[String, Node] = {}

func _ready() -> void:
	# Build lookup-map and connect finished() for all child states
	for s in get_children():
		states[s.name] = s
		if s.has_signal("finished"):
			s.finished.connect(Callable(self, "_on_state_finished"))
	_change_state(initial_state_name)

func _physics_process(delta: float) -> void:
	# Safely call _physics_update(owner, delta) if the state has it
	if current_state and current_state.has_method("_physics_update"):
		current_state._physics_update(get_parent(), delta)

func _on_state_finished(next_state_name: String = "") -> void:
	# Support signal finished() or finished("StateName")
	if next_state_name != "" and states.has(next_state_name):
		_change_state(next_state_name)
	elif states.has(initial_state_name):
		_change_state(initial_state_name)

func _change_state(name: String) -> void:
	# Notify old state (if it has exit()):
	if current_state and current_state.has_method("exit"):
		current_state.exit(get_parent())
	# Switch
	current_state = states.get(name)
	if not current_state:
		push_error("StateManager: State '%s' not found!" % name)
		return
	# Call enter(owner) if exists
	if current_state.has_method("enter"):
		current_state.enter(get_parent())
