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
export var soft_collision_amt = 400
export var wander_target_buffer = 4

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = CHASE

onready var stats = $Stats
onready var liveAnimation: AnimatedSprite = $LiveAnimation
onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var playerDetectionZone: PlayerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController: WanderController = $WanderController
onready var hurtAnimationPlayer = $HurtAnimationPlayer

# Called when the node enters the scene tree for the first time.refusing to merge unrelated histories
func _ready() -> void:
	randomize()
	state = pick_random_state([IDLE, WANDER])
	liveAnimation.play()
	animationPlayer.play("FlyShadow")
	hurtAnimationPlayer.play("Stop")

func _physics_process(delta: float) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				go_to_random_state()
		WANDER:
			seek_player()
			
			if wanderController.get_time_left() == 0:
				go_to_random_state()
				
			accelerate_towards_point(wanderController.target_position, delta)
			
			if global_position.distance_to(wanderController.target_position) <= wander_target_buffer:
				go_to_random_state()
			
		CHASE:
			chase_player(delta)

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * soft_collision_amt
	velocity = move_and_slide(velocity)

func seek_player() -> void:
	if playerDetectionZone.can_see_player():
		state = CHASE
		

func pick_random_state(state_list: Array) -> int:
	state_list.shuffle()
	return state_list.pop_front()

func go_to_random_state() -> void:
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,2))

func chase_player(delta: float) -> void:
	if !playerDetectionZone.can_see_player():
		state = IDLE
		
	var player = playerDetectionZone.player
	if player != null:
		accelerate_towards_point(player.global_position, delta)

func accelerate_towards_point(point: Vector2, delta: float) -> void:
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	liveAnimation.flip_h = velocity.x < 0

func _on_Hurtbox_area_entered(area: Area2D) -> void:
	stats.health -= area.damage
	knockback = area.knockback_vector * knockback_power
	hurtbox.create_hit_effect()
	hurtbox.start_invincibility(0.4)

func _on_Stats_no_health() -> void:
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_Hurtbox_invincibility_started() -> void:
	hurtAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended() -> void:
	hurtAnimationPlayer.play("Stop")
