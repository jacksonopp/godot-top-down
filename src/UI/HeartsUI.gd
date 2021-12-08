extends Control

var stats = PlayerStats

func _ready() -> void:
	pass
	
func update_health_ui(value: int) -> void:
	print("new health: ",value)
