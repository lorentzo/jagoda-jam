extends CharacterBody2D

const WALK_SPEED = 150.0

func _physics_process(delta):
	var walk_velocity = Vector2.ZERO
	
	if Input.is_action_pressed("walk-left"):
		walk_velocity.x = -1
	elif Input.is_action_pressed("walk-right"):
		walk_velocity.x = 1
	
	if Input.is_action_pressed("walk-up"):
		walk_velocity.y = -1
	elif Input.is_action_pressed("walk-down"):
		walk_velocity.y = 1

	self.velocity = walk_velocity.normalized() * WALK_SPEED

	move_and_slide()
