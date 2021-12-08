extends Node

export(int) var max_health = 1 setget set_max_health
var health = max_health setget set_health

func _ready() -> void:
	health = max_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_health(value: int) -> void:
	health = value
	emit_signal("health_changed", value)
	if health <= 0:
		emit_signal("no_health")

func set_max_health(value: int) -> void:
	max_health = value
	emit_signal("max_health_changed", value)
