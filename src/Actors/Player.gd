extends Actor

export (int) var sprint_animation_speed = 2.0
export (int) var walk_animation_speed = 1.0

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var roll_vector = Vector2.LEFT

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox


func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

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

func move_state(delta: float) -> void:
	var direction_vector := calculate_direction()

	move_actor(direction_vector, walk_speed, delta)
	set_animation_vector(direction_vector)
	
	if direction_vector != Vector2.ZERO:		
		animationState.travel("Run")
	else:
		animationState.travel("Idle")

func roll_state(delta: float) -> void:
	velocity = roll_vector * roll_speed
	animationState.travel("Roll")
	move()

func roll_animation_finished() -> void:
	velocity = velocity * 0.8
	state = MOVE

func attack_state(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	animationState.travel("Attack")
	move()

func attack_animation_finished() -> void:
	state = MOVE
	
func move():
	velocity = move_and_slide(velocity)

func calculate_direction() -> Vector2:
	var input_vector := Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	if is_moving_diagonally(input_vector):
		input_vector = input_vector.normalized()
	
	return input_vector

func set_animation_vector(input_vector: Vector2) -> void:
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector.normalized()
		swordHitbox.knockback_vector = input_vector.normalized()
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
