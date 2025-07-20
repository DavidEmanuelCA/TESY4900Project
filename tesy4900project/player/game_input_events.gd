class_name  GameInputEvents
extends Node

static func movement_input() -> float:
	var direction : float = Input.get_axis("move_left", "move_right")
	return direction

static func jump_input() -> bool:
	var jump_input : bool = Input.is_action_just_pressed("jump")
	return jump_input

static func throw_input() -> bool:
	var throw_input : bool = Input.is_action_just_pressed("throw")
	return throw_input

static func defend_input() -> bool:
	var defend_input : bool = Input.is_action_just_pressed("defend")
	return defend_input

static func attack1_input() -> bool:
	var attack1_input : bool = Input.is_action_just_pressed("attack1")
	return attack1_input

static func attack2_input() -> bool:
	var attack2_input : bool = Input.is_action_just_pressed("attack2")
	return attack2_input

static func attack3_input() -> bool:
	var attack3_input : bool = Input.is_action_just_pressed("attack3")
	return attack3_input

static func fall_input() -> bool:
	var fall_input : bool = Input.is_action_just_pressed("force_fall")
	return fall_input
