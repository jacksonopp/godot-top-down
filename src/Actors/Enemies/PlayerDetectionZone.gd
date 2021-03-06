extends Area2D

class_name PlayerDetectionZone

var player = null

func _physics_process(_delta: float) -> void:
	pass

func can_see_player() -> bool:
	return player != null


func _on_PlayerDetectionZone_body_entered(body: Node) -> void:
	player = body


func _on_PlayerDetectionZone_body_exited(_body: Node) -> void:
	player = null
