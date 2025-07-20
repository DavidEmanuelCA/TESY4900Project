extends AnimatedSprite2D

var shuriken_impact_effect = preload("res://player/shuriken_impact_effect.tscn")

var SPEED : int = 500
var direction : int
var damage_amount : int = 1
var move_x_direction : bool

func  _physics_process(delta: float) -> void:
	if move_x_direction:
		move_local_x(direction * delta * SPEED)

func _on_timer_timeout() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	print("Shuriken area entered")
	shuriken_impact()

func _on_hitbox_body_entered(body: Node2D) -> void:
	print("Shuriken body entered")
	shuriken_impact()

func get_damage_amount() -> int:
	return damage_amount

func shuriken_impact():
	var shuriken_impact_effect_instance = shuriken_impact_effect.instantiate() as Node2D
	shuriken_impact_effect_instance.global_position = global_position
	get_parent().add_child(shuriken_impact_effect_instance)
	queue_free()
