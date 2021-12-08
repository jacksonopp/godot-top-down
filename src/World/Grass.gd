extends Node2D

const GrassEffect = preload("res://src/Effects/GrassEffect.tscn")

export var time_to_free = 1.0

#onready var grassEffect = $GrassEffect
onready var grassSprite = $GrassSprite
onready var grassHurtbox = $Hurtbox/CollisionShape2D

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	destroy_grass()
	queue_free()

func destroy_grass() -> void:
	var grassEffect = GrassEffect.instance()
	get_parent().add_child(grassEffect)
	grassEffect.global_position = global_position
