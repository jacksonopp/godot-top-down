extends Control

var stats = PlayerStats

onready var heartsUIEmpty = $HeartsUIEmpty
onready var heartsUIFull = $HeartsUIFull

func _ready() -> void:
	stats.connect("health_changed", self, "update_hearts")
	stats.connect("max_health_changed", self, "update_max_hearts")
	update_hearts(stats.max_health)
	update_max_hearts(stats.max_health)
	
func update_hearts(value: int) -> void:
	heartsUIFull.rect_size.x = value * 15

func update_max_hearts(value: int) -> void:
	heartsUIEmpty.rect_size.x = value * 15
