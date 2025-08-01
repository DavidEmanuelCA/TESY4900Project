extends Node
class_name StateManager

@export var initial_state_name: String = ""
var _current: Node = null
var _states: Dictionary[String, Node] = {}

var owner_ref: Node = null
var injected_health: Node = null

func _ready() -> void:
	for child in get_children():
		_states[child.name] = child
		if child.has_signal("finished"):
			child.finished.connect(_on_state_finished)
	_switch_to(initial_state_name)

func physics_process(delta: float) -> void:
	if _current and _current.has_method("physics_update"):
		_current.physics_update(owner_ref, delta)

func init_owner_and_health(owner_node: Node, health_node: Node) -> void:
	owner_ref = owner_node
	injected_health = health_node

func _switch_to(state_name: String) -> void:
	if _current and _current.has_method("exit"):
		_current.exit(owner_ref)
	_current = _states.get(state_name)
	if not _current:
		push_error("CombatStateManager: Missing state '%s' in manager" % state_name)
		return
	if _current.has_method("enter"):
		_current.enter(owner_ref)

func _on_state_finished(next_state_name: String) -> void:
	_switch_to(next_state_name)
