extends Area2D

const HitEffect = preload("res://src/Effects/HitEffect.tscn")

#func _on_Hurtbox_area_entered(area: Area2D) -> void:



func _on_Hurtbox_area_entered(area: Area2D) -> void:
	print('should see this')
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position
