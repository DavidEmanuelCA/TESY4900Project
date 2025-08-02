extends Node
class_name StateManager

@export var initial_state_name: String = ""

var _current: Node = null
var _states: Dictionary = {}

var owner_ref: Node = null
var injected_health: Node = null

func _ready() -> void:
	# Cache states from children
	for child in get_children():
		if child is Node:
			_states[child.name] = child
			# Connect state's finished signal if it has one
			if child.has_signal("finished"):
				child.finished.connect(_on_state_finished)
	# Start in the initial state if provided
	if initial_state_name != "":
		switch_to(initial_state_name)

func _physics_process(delta: float) -> void:
	if _current and "physics_update" in _current:
		_current.physics_update(owner_ref, delta)

func init_owner_and_health(owner_node: Node, health_node: Node) -> void:
	owner_ref = owner_node
	injected_health = health_node

func switch_to(state_name: String) -> void:
	var next_state: Node = _states.get(state_name, null)
	if not next_state:
		push_error("StateManager: Missing state '%s' in manager" % state_name)
		return
	# Exit current state
	if _current and "exit" in _current:
		_current.exit(owner_ref)
	# Switch to new state
	_current = next_state
	
	# Enter new state
	if "enter" in _current:
		_current.enter(owner_ref)

func _on_state_finished(next_state_name: String) -> void:
	switch_to(next_state_name)
