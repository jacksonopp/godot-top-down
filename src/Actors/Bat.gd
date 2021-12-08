extends KinematicBody2D

const EnemyDeathEffect = preload("res://src/Effects/EnemyDeathEffect.tscn")

export var knockback_friction = 200
export var knockback_power = 100

var knockback = Vector2.ZERO

onready var stats = $Stats
onready var liveAnimation = $LiveAnimation
onready var dieAnimation = $DieAnimation
onready var animationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.refusing to merge unrelated histories
func _ready() -> void:
	liveAnimation.play()
	animationPlayer.play("FlyShadow")
	print(stats.max_health)
	print(stats.health)

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, knockback_friction * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockback = area.knockback_vector * knockback_power
	

func _on_Stats_no_health() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_DieAnimation_animation_finished() -> void:
	queue_free()
