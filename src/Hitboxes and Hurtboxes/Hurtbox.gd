extends Area2D

const HitEffect = preload("res://src/Effects/HitEffect.tscn")

var invincible = false setget set_invincible

onready var timer = $Timer

signal invincibility_started
signal invincibility_ended

func create_hit_effect() -> void:
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position

func set_invincible(value: bool) -> void:
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")

# starts invincibility
func start_invincibility(duration: float) -> void:
	self.invincible = true
	timer.start(duration)

# ends invincibility on timeout
func _on_Timer_timeout() -> void:
	self.invincible = false

func _on_Hurtbox_invincibility_started() -> void:
	print("invincible: ", !monitorable)
	set_deferred("monitorable",  false)

func _on_Hurtbox_invincibility_ended() -> void:
	print("invincible: ", !monitorable)
	monitorable = true
