extends AnimatedSprite2D

var SPEED : int = 600
var direction : int

func  _physics_process(delta: float) -> void:
	move_local_x(direction * delta * SPEED)


func _on_timer_timeout() -> void:
	queue_free()
