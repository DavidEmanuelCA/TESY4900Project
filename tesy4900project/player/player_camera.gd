extends Camera2D

@export_category("Follow Character")
@export var player: CharacterBody2D
@export_category("Camera Smoothing")
@export var smoothing_enabled: bool
@export_range(1, 10) var smoothing_distance: int = 8

var weight: float

func _ready() -> void:
	add_to_group("Cameras")  # Allow SettingsManager to find this
	weight = float(11 - smoothing_distance) / 100
	# Ensure we don't double-connect
	if not get_viewport().size_changed.is_connected(_adjust_zoom):
		get_viewport().size_changed.connect(_adjust_zoom)
	_adjust_zoom()  # Initial zoom calculation


func _physics_process(delta: float) -> void:
	if player:
		var camera_position: Vector2
		if smoothing_enabled:
			camera_position = lerp(global_position, player.global_position, weight)
		else:
			camera_position = player.global_position
		global_position = camera_position.floor()

func _adjust_zoom() -> void:
	var base_res = Vector2(2560, 1440)  # Reference resolution
	var current_res = get_viewport().get_visible_rect().size
	# Zoom baseline: tighter at 720p by default
	var scale_factor = base_res.y / current_res.y
	# Make higher resolutions zoom even closer (tight view)
	if current_res.y >= 1440:
		scale_factor *= 2.0  # Aggressive zoom for 1440p+
	elif current_res.y >= 1080:
		scale_factor *= 1.8  # Mild zoom for 1080p
	else:
		scale_factor *= 1.4  # Already zoomed in at 720p
	# Clamp zoom so it doesn't get absurdly close or too far out
	scale_factor = clamp(scale_factor, 1.0, 2.0)
	zoom = Vector2(scale_factor, scale_factor)
