extends Node

# Emitted whenever the player's health changes (UI listens to this)
signal player_health_changed(current: int, max_health: int)

# Emitted when the player performs a defend action (AI listens to this to punish)
signal player_defended
