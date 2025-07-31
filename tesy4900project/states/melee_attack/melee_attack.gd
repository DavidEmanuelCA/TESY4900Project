extends Node
class_name MeleeAttackState

signal finished(next_state: String)

@export var animation_name: String = "attack"
@export var damage_amount: int = 1
@export var attack_duration: float = 0.5
@export var next_state_name: String = "Idle"
@export var cooldown_time: float = 0.3
@export var hitbox_node_name: String = "AttackArea"

var _cooldown_timer: Timer

func _ready() -> void:
	_cooldown_timer = Timer.new()
	add_child(_cooldown_timer)
	_cooldown_timer.wait_time = cooldown_time
	_cooldown_timer.one_shot = true
	_cooldown_timer.autostart = false

	# disable hitbox initially
	var area = get_node_or_null(hitbox_node_name)
	if area:
		area.monitoring = false

func _enter(owner: Node) -> void:
	var anim = owner.get_node_or_null("AnimatedSprite2D")
	if anim:
		anim.play(animation_name)
	_activate_hitbox(owner)
	_cooldown_timer.start()
	await _cooldown_timer.timeout
	_deactivate_hitbox()
	emit_signal("finished", next_state_name)


func _activate_hitbox(owner: Node) -> void:
	var area = get_node_or_null(hitbox_node_name)
	if area and area is Area2D:
		area.monitoring = true
		area.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

func _deactivate_hitbox() -> void:
	var area = get_node_or_null(hitbox_node_name)
	if area and area is Area2D:
		area.monitoring = false

func _on_hitbox_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage(damage_amount)
