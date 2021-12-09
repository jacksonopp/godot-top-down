extends Actor

export (int) var sprint_animation_speed = 2.0
export (int) var walk_animation_speed = 1.0
export (float) var invincibility_time = 0.5

enum {
	MOVE,
	ROLL,
	ATTACK
}

const PlayerHurtSound = preload("res://src/Actors/PlayerHurtSound.tscn")

var state = MOVE
var roll_vector = Vector2.LEFT
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

# runs when ready
func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector
	stats.connect("no_health", self, "queue_free")
	blinkAnimationPlayer.play("Stop")

# Runs every physics frame
func _physics_process(delta: float) -> void:
#	State machine
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
			
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	elif Input.is_action_just_pressed("attack"):
		state = ATTACK

# Move state part of state machine
func move_state(delta: float) -> void:
	var direction_vector := calculate_direction()

	move_actor(direction_vector, walk_speed, delta)
	set_animation_vector(direction_vector)
	
	if direction_vector != Vector2.ZERO:		
		animationState.travel("Run")
	else:
		animationState.travel("Idle")

# Roll state part of state machine
func roll_state(_delta: float) -> void:
	velocity = roll_vector * roll_speed
	animationState.travel("Roll")
	move()

# Resets the roll animation state
func roll_animation_finished() -> void:
	velocity = velocity * 0.8
	state = MOVE

# The attack part of the state machine
func attack_state(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	animationState.travel("Attack")
	move()

# Resets the attack animation state
func attack_animation_finished() -> void:
	state = MOVE
	
# Moves in the direction of velocity
func move():
	velocity = move_and_slide(velocity)

# Calculates the direction vector
func calculate_direction() -> Vector2:
	var input_vector := Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if is_moving_diagonally(input_vector):
		input_vector = input_vector.normalized()
	
	return input_vector

# Sets the animation vector
func set_animation_vector(input_vector: Vector2) -> void:
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector.normalized()
		swordHitbox.knockback_vector = input_vector.normalized()
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)

# When an enemy hits the player
func _on_Hurtbox_area_entered(area: HitBox) -> void:
	if state != ROLL and !hurtbox.invincible:
		stats.health -= area.damage
		hurtbox.start_invincibility(invincibility_time)
		hurtbox.create_hit_effect()
		var playerHurtSound = PlayerHurtSound.instance()
		get_tree().current_scene.add_child(playerHurtSound)


func _on_Hurtbox_invincibility_started() -> void:
	blinkAnimationPlayer.play("Start")


func _on_Hurtbox_invincibility_ended() -> void:
	blinkAnimationPlayer.play("Stop")
