extends CharacterBody2D

var shuriken = preload("res://shuriken.tscn")
var player_death_effect = preload("res://player/player_death_effect/player_death_effect.tscn")

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hand: Marker2D = $Hand

func player_death():
	var player_death_effect_instance = player_death_effect.instantiate() as Node2D
	player_death_effect_instance.global_position = global_position
	get_parent().add_child(player_death_effect_instance)
	queue_free()

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		print("Enemy Entered ", body.damage_amount)
		
		var tween = get_tree().create_tween()
		tween.tween_property(animated_sprite_2d, "material:shader_parammeter/enabled", true, 0)
		tween.tween_property(animated_sprite_2d, "material:shader_parammeter/enabled", false, 0.2)
		
		HealthManager.decrease_health(body.damage_amount)
		
		if HealthManager.current_health == 0:
			player_death()
