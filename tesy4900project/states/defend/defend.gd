extends Node
class_name Defend

signal finished(next_state: String)

@export var defend_animation: String = "defend"
@export var sprite_path: NodePath = "AnimatedSprite2D"
@export var next_state_name: String = "Idle"

var _anim_sprite: AnimatedSprite2D
var _conn_anim_ref: Callable

func enter(owner: Node) -> void:
	# Only defend when grounded (if applicable)
	if owner.has_method("is_on_floor") and not owner.is_on_floor():
		finished.emit(next_state_name)
		return
	# Mark owner as defending (if supported)
	if owner.has_method("set"):
		owner.set("is_defending", true)
	# Play defend animation
	_anim_sprite = owner.get_node_or_null(sprite_path)
	if _anim_sprite:
		_conn_anim_ref = Callable(self, "_on_anim_finished")
		if not _anim_sprite.animation_finished.is_connected(_conn_anim_ref):
			_anim_sprite.animation_finished.connect(_conn_anim_ref)
		_anim_sprite.play(defend_animation)
	else:
		# No animation? End defense immediately
		_finish_block(owner)

func physics_update(owner: Node, delta: float) -> void:
	# Typically stationary while defending; add logic here if needed
	pass

func exit(owner: Node) -> void:
	# Always ensure defense is cleared
	_cleanup(owner)

# --- Internal Helpers ---
func _on_anim_finished(anim_name: StringName) -> void:
	if anim_name == defend_animation:
		_finish_block(get_parent().owner_ref) # Use state manager's owner_ref

func _finish_block(owner: Node) -> void:
	# Remove invincibility flag
	if owner.has_method("set"):
		owner.set("is_defending", false)
	finished.emit(next_state_name)
	_cleanup(owner)

func _cleanup(owner: Node) -> void:
	# Disconnect animation signal
	if _anim_sprite and _conn_anim_ref.is_valid() and _anim_sprite.animation_finished.is_connected(_conn_anim_ref):
		_anim_sprite.animation_finished.disconnect(_conn_anim_ref)
	# Clear cached references
	_anim_sprite = null
	_conn_anim_ref = Callable()
