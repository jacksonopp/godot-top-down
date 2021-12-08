extends KinematicBody2D

const EnemyDeathEffect = preload("res://src/Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

export var friction = 200
export var knockback_power = 100

export var acceleration = 300
export var max_speed = 50

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = CHASE

onready var stats = $Stats
onready var liveAnimation: AnimatedSprite = $LiveAnimation
onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var playerDetectionZone: PlayerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox

# Called when the node enters the scene tree for the first time.refusing to merge unrelated histories
func _ready() -> void:
	liveAnimation.play()
	animationPlayer.play("FlyShadow")
	print(stats.max_health)
	print(stats.health)

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			chase_player(delta)
		
	liveAnimation.flip_h = velocity.x < 0
	velocity = move_and_slide(velocity)

func seek_player() -> void:
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func chase_player(delta: float) -> void:
	if !playerDetectionZone.can_see_player():
		state = IDLE
		
	var player = playerDetectionZone.player
	if player != null:
		var direction = (player.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockback = area.knockback_vector * knockback_power
	hurtbox.create_hit_effect()
	

func _on_Stats_no_health() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
