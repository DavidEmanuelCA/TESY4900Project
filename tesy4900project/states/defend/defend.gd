extends Node
class_name DefendState

signal finished()

@export var defend_animation: String = "defend"
@export var sprite_path: NodePath = "AnimatedSprite2D"

var _owner         : Node
var _anim_sprite   : AnimatedSprite2D
var _conn_anim_ref : Callable

func enter(previous: String = "", data: Dictionary = {}) -> void:
	_owner = data.get("entity")
	if not (_owner and _owner.is_inside_tree()):
		push_error("DefendState.enter(): missing or invalid 'entity'")
		return
	# Only defend when grounded
	if not _owner.is_on_floor():
		emit_signal("finished")
		return
	# Make invincible while blocking
	_owner.set("is_defending", true)
	_anim_sprite = _owner.get_node_or_null(sprite_path)
	if _anim_sprite and _anim_sprite.has_signal("animation_finished"):
		_conn_anim_ref = Callable(self, "_on_anim_finished")
		if not _anim_sprite.animation_finished.is_connected(_conn_anim_ref):
			_anim_sprite.animation_finished.connect(_conn_anim_ref)
		_anim_sprite.play(defend_animation)
	else:
		# If no animation is available, finish immediately
		_finish_block()

func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == defend_animation:
		_finish_block()

func exit() -> void:
	_cleanup()

func _finish_block() -> void:
	_owner.set("is_defending", false)
	emit_signal("finished")
	_cleanup()

func _cleanup() -> void:
	if _anim_sprite and _conn_anim_ref.is_valid():
		if _anim_sprite.animation_finished.is_connected(_conn_anim_ref):
			_anim_sprite.animation_finished.disconnect(_conn_anim_ref)
	_owner = null
	_conn_anim_ref = Callable()
