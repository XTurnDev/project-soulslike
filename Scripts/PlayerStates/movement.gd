extends State


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var player: CharacterBody3D

func Enter():
	player = get_parent().get_parent()

func PhysicsUpdate(_delta: float):
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_vector = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if Input.is_action_pressed("move_jump"):
		Transitioned.emit(self, "jump")
	
	if input_vector.length_squared() > 0.01:
		
		
		var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			player.velocity.x = direction.x * SPEED
			player.velocity.z = direction.z * SPEED
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, SPEED)
			player.velocity.z = move_toward(player.velocity.z, 0, SPEED)
	
	else:
		Transitioned.emit(self, "idle")
