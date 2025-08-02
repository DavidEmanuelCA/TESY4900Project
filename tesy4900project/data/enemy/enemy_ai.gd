extends Node
class_name EnemyAI

@export var detection_range: float = 200.0
@export var attack_range: float = 50.0
@export var chase_state: String = "Chase"
@export var idle_state: String = "Idle"
@export var normal_attacks: Array[String] = ["MeleeAttack1", "MeleeAttack2", "MeleeAttack3"]
@export var heavy_attack: String = "HeavyAttack"

@export var combo_delay: float = 0.3 # Time between combo attacks
@export var post_defend_window: float = 0.4 # Time after player defends to punish

var state_manager: StateManager
var owner_ref: Node
var player_ref: Node
var last_player_defend_time: float = -999.0
var combo_queue: Array[String] = []
var combo_timer: Timer

func _ready() -> void:
	# Get references
	owner_ref = get_parent()
	state_manager = owner_ref.get_node_or_null("StateManager")
	player_ref = get_tree().get_first_node_in_group("Player")

	if not state_manager:
		push_error("EnemyAI: No StateManager found for this enemy.")
	if not player_ref:
		push_warning("EnemyAI: No Player found in the scene.")

	# Timer for chaining combo attacks
	combo_timer = Timer.new()
	combo_timer.one_shot = true
	add_child(combo_timer)

	# Listen for player's defend signal globally
	Signalbus.connect("player_defended", Callable(self, "_on_player_defended"))

func _physics_process(delta: float) -> void:
	if not (state_manager and player_ref):
		return

	var dist_to_player = owner_ref.global_position.distance_to(player_ref.global_position)

	if dist_to_player <= attack_range and owner_ref.is_on_floor():
		_decide_attack()
	elif dist_to_player <= detection_range:
		_request_state(chase_state)
	else:
		_request_state(idle_state)

# --- Combat Decision Logic ---
func _decide_attack() -> void:
	# Heavy attack punish after player defends
	if Time.get_ticks_msec() / 1000.0 - last_player_defend_time <= post_defend_window:
		_request_state(heavy_attack)
		return

	# Continue combo if queued
	if combo_queue.size() > 0:
		if combo_timer.is_stopped():
			var next_attack = combo_queue.pop_front()
			_request_state(next_attack)
			combo_timer.start(combo_delay)
		return

	# Start a new combo or heavy attack randomly
	if randi() % 100 < 70: 
		_start_combo()
	else:
		_request_state(heavy_attack)

func _start_combo() -> void:
	# Shuffle normal attacks for variety and queue them
	combo_queue = normal_attacks.duplicate()
	combo_queue.shuffle()

	# Perform first attack immediately
	var first_attack = combo_queue.pop_front()
	_request_state(first_attack)
	combo_timer.start(combo_delay)

# --- State Switching ---
func _request_state(new_state: String) -> void:
	if state_manager and state_manager._current and state_manager._current.name != new_state:
		state_manager.switch_to(new_state)

# --- Respond to Player Defend ---
func _on_player_defended() -> void:
	last_player_defend_time = Time.get_ticks_msec() / 1000.0
