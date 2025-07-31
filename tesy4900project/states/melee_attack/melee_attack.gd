extends Node
class_name MeleeAttackState

signal finished(next_state: String)

@export var animation_name: String = "attack"
@export var damage_amount: int = 1
@export var hitbox_scene: PackedScene
@export var attack_duration: float = 0.5
@export var next_state_name: String = "Idle"
@export var cooldown_time: float = 0.3

var _cooldown_timer: Timer

func _ready() -> void:
	_cooldown_timer = Timer.new()
	add_child(_cooldown_timer)
	_cooldown_timer.wait_time = cooldown_time
	_cooldown_timer.one_shot = true
	_cooldown_timer.autostart = false

func _enter(owner: Node) -> void:
	var anim_node = owner.get_node_or_null("AnimatedSprite2D")
	if anim_node:
		anim_node.play(animation_name)

	if hitbox_scene:
		_spawn_hitbox(owner)

	_cooldown_timer.start()
	await _cooldown_timer.timeout
	emit_signal("finished", next_state_name)

func _spawn_hitbox(owner: Node) -> void:
	var hb = hitbox_scene.instantiate()
	owner.add_child(hb)
	if hb.has_method("setup"):
		hb.setup(owner, damage_amount)
