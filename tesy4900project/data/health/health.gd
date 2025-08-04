extends Node
class_name Health

@export var max_health: int = 3
@export var heal_per_sec: float = 0.0
@export var invulnerability_time: float = 0.0

var current_health: int
var is_invulnerable: bool = false

signal health_changed(current: int, max: int)
signal died()
signal health_initialized(current: int, max_health: int)

var _regen_timer: float = 0.0
var _invuln_timer: float = 0.0

func _ready() -> void:
	reset()
	set_process(heal_per_sec > 0 or invulnerability_time > 0)
	emit_signal("health_initialized", current_health, max_health)
	if heal_per_sec > 0:
		set_process(true)

# --- Core Health Management ---
func reset() -> void:
	current_health = max_health
	emit_health_changed()

func damage(amount: int) -> void:
	if amount <= 0 or is_invulnerable:
		return
	current_health = clamp(current_health - amount, 0, max_health)
	emit_health_changed()
	if current_health == 0:
		emit_signal("died")
	else:
		_start_invulnerability()

func heal(amount: int) -> void:
	if amount <= 0 or current_health == 0: # Can't heal dead entities
		return
	current_health = clamp(current_health + amount, 0, max_health)
	emit_health_changed()

# --- Invulnerability Logic ---
func _start_invulnerability() -> void:
	if invulnerability_time > 0:
		is_invulnerable = true
		_invuln_timer = invulnerability_time

# --- Frame Processing ---
func _process(delta: float) -> void:
	# Handle invulnerability decay
	if is_invulnerable:
		_invuln_timer -= delta
		if _invuln_timer <= 0.0:
			is_invulnerable = false
	# Handle passive regeneration
	if heal_per_sec > 0 and current_health > 0:
		_regen_timer += delta
		if _regen_timer >= 1.0:
			heal(heal_per_sec)
			_regen_timer = 0.0

# --- Utility ---
func emit_health_changed() -> void:
	emit_signal("health_changed", current_health, max_health)

func is_dead() -> bool:
	return current_health <= 0
