extends KinematicBody2D

class_name Actor

# How quickly the actor gets up to speed
export var acceleration = 1000

# A the walking speed
export var walk_speed = 80

# The sprinting speed
export var roll_speed = 100

# How quickly the actor slows to a halt
export var friction = 1000

var velocity = Vector2.ZERO

func move_actor(direction: Vector2, max_speed: float, delta: float) -> void:
	if direction != Vector2.ZERO:
		velocity = velocity.move_toward(direction * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move()
		
func is_moving_diagonally(vector: Vector2) -> bool:
	var moving_diagonally = false
	
	if vector.x == 1 or vector.x == -1:
		if vector.y == 1 or vector.y == -1:
			moving_diagonally = true
	
	return moving_diagonally

func move() -> void:
	velocity = move_and_slide(velocity)
