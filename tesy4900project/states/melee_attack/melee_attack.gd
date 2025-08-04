extends Node
class_name MeleeAttack

signal finished(next_state: String)

@export var animation_name: String = "attack"
@export var damage_amount: int = 1
@export var hitbox_node_path: NodePath = "AttackArea"
@export var sprite_path: NodePath = "AnimatedSprite2D"
@export var return_state_name: String = "Idle"

var _anim: AnimatedSprite2D
var _conn_anim_ref: Callable
var _conn_hitbox_ref: Callable
var hitbox: Area2D

func enter(owner: Node) -> void:
	# Resolve hitbox dynamically and tag it here
	hitbox = $AttackArea
	if hitbox:
		hitbox.set_meta("is_attack_hitbox", true)
		hitbox.set("damage", damage_amount)
		hitbox.monitoring = true
		if not hitbox.body_entered.is_connected(_on_hitbox_body_entered):
			hitbox.body_entered.connect(_on_hitbox_body_entered)
	# Ensure owner is a CharacterBody2D (required for floor check)
	if not (owner is CharacterBody2D):
		push_error("MeleeAttack.enter(): Owner is not a CharacterBody2D")
		_finish_immediately(owner)
		return
	# Must be grounded to perform attack
	if not owner.is_on_floor():
		_finish_immediately(owner)
		return
	# Play attack animation
	_anim = owner.get_node_or_null(sprite_path)
	if _anim:
		_conn_anim_ref = Callable(self, "_on_animation_finished")
		if not _anim.animation_finished.is_connected(_conn_anim_ref):
			_anim.animation_finished.connect(_conn_anim_ref)
		_anim.play(animation_name)
	else:
		push_error("MeleeAttack.enter(): AnimatedSprite2D not found at %s" % sprite_path)
		_finish_immediately(owner)

func physics_update(owner: Node, delta: float) -> void:
	pass

func exit(owner: Node) -> void:
	if hitbox and hitbox.body_entered.is_connected(_on_hitbox_body_entered):
		hitbox.body_entered.disconnect(_on_hitbox_body_entered)
	hitbox.monitoring = false
	_cleanup(owner)

func _on_hitbox_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage(damage_amount)

func _on_animation_finished(anim: String) -> void:
	if anim == animation_name:
		_finish_immediately(get_parent().owner_ref) # Use state manager's owner_ref

func _finish_immediately(owner: Node) -> void:
	finished.emit(return_state_name)
	_cleanup(owner)

func _cleanup(owner: Node) -> void:
	# Disconnect animation listener
	if _anim and _conn_anim_ref.is_valid() and _anim.animation_finished.is_connected(_conn_anim_ref):
		_anim.animation_finished.disconnect(_conn_anim_ref)
	# Disconnect hitbox
	var hb = owner.get_node_or_null(hitbox_node_path)
	if hb and hb is Area2D and _conn_hitbox_ref.is_valid() and hb.body_entered.is_connected(_conn_hitbox_ref):
		hb.body_entered.disconnect(_conn_hitbox_ref)
		hb.monitoring = false
	# Reset cached references
	_anim = null
	_conn_anim_ref = Callable()
	_conn_hitbox_ref = Callable()
