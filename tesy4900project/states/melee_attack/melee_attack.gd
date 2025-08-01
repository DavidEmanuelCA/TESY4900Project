extends Node
class_name MeleeAttackState

signal finished()

@export var animation_name: String = "attack"
@export var damage_amount: int = 1
@export var hitbox_node_name: NodePath = "AttackArea"
@export var sprite_path: NodePath = "AnimatedSprite2D"

var _owner           : CharacterBody2D
var _anim            : AnimatedSprite2D
var _conn_anim_ref   : Callable
var _conn_hitbox_ref : Callable

func enter(_prev_state:String = "", data:Dictionary = {}) -> void:
	_owner = data.get("entity")
	if not (_owner and _owner.is_inside_tree()):
		push_error("MeleeAttackState.enter(): Missing or invalid 'entity'")
		return
	if not _owner.is_on_floor():
		emit_signal("finished")
		return
	_anim = _owner.get_node_or_null(sprite_path)
	if _anim:
		_conn_anim_ref = Callable(self, "_on_animation_finished")
		if not _anim.animation_finished.is_connected(_conn_anim_ref):
			_anim.animation_finished.connect(_conn_anim_ref)
		_anim.play(animation_name)
		_activate_hitbox()
	else:
		push_error("MeleeAttackState: AnimatedSprite2D not found at " + str(sprite_path))
		_finish_immediately()

func _activate_hitbox() -> void:
	var hb = _owner.get_node_or_null(hitbox_node_name)
	if hb and hb is Area2D:
		hb.monitoring = true
		_conn_hitbox_ref = Callable(self, "_on_hitbox_body_entered")
		if not hb.body_entered.is_connected(_conn_hitbox_ref):
			hb.body_entered.connect(_conn_hitbox_ref)
	# else: optional warning if missing

func _on_hitbox_body_entered(body: Node) -> void:
	if body.has_method("damage"):
		body.damage(damage_amount)

func _on_animation_finished(anim:String) -> void:
	if anim == animation_name:
		_finish_immediately()

func exit() -> void:
	_cleanup()

func _finish_immediately() -> void:
	emit_signal("finished")
	_cleanup()

func _cleanup() -> void:
	if _anim and _conn_anim_ref.is_valid() and _anim.animation_finished.is_connected(_conn_anim_ref):
		_anim.animation_finished.disconnect(_conn_anim_ref)
	var hb = _owner.get_node_or_null(hitbox_node_name)
	if hb and hb is Area2D and _conn_hitbox_ref.is_valid() and hb.body_entered.is_connected(_conn_hitbox_ref):
		hb.body_entered.disconnect(_conn_hitbox_ref)
		hb.monitoring = false
	_anim = null
	_owner = null
	_conn_anim_ref = Callable()
	_conn_hitbox_ref = Callable()
