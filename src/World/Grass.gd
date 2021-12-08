extends Node2D

export var time_to_free = 1.0

onready var grassEffect = $GrassEffect
onready var grassSprite = $GrassSprite
onready var grassHurtbox = $Hurtbox/CollisionShape2D

func _ready() -> void:
	grassEffect.visible = false


func _on_GrassEffect_animation_finished() -> void:
	yield(get_tree().create_timer(time_to_free), "timeout")
	queue_free()

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	destroy_grass()

func destroy_grass() -> void:
	grassHurtbox.disabled = true
	grassSprite.visible = false;
	grassEffect.visible = true
	grassEffect.play("effect")
