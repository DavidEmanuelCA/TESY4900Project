extends Node
class_name Health

@export var max_health: int = 3
var current_health: int

@export var heal_per_sec: float = 0.0
@export var invulnerability_time: float = 0.0
var is_invulnerable: bool = false

signal health_changed(current: int, max: int)
signal died()

var _regen_timer := 0.0
var _invuln_timer := 0.0

func _ready():
	reset()
	if heal_per_sec > 0:
		set_process(true)

func reset():
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)

func damage(amount: int) -> void:
	print("Damage! CUrrent: ", current_health, " - Amount: ", amount)
	if amount <= 0 or is_invulnerable:
		return
	current_health = clamp(current_health - amount, 0, max_health)
	emit_signal("health_changed", current_health, max_health)
	if current_health == 0:
		emit_signal("died")
	else:
		if invulnerability_time > 0:
			is_invulnerable = true
			_invuln_timer = invulnerability_time

func heal(amount: int) -> void:
	if amount <= 0 or current_health == 0:
		return
	current_health = clamp(current_health + amount, 0, max_health)
	emit_signal("health_changed", current_health, max_health)

func _process(delta: float) -> void:
	if is_invulnerable:
		_invuln_timer -= delta
		if _invuln_timer <= 0:
			is_invulnerable = false
	if heal_per_sec > 0 and current_health > 0:
		_regen_timer += delta
		if _regen_timer >= 1.0:
			heal(heal_per_sec)
			_regen_timer = 0.0
