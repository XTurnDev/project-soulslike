extends State

const JUMP_FORCE: float = 3
const speed = 3.0

@onready var player: CharacterBody3D

func Enter():
	player = get_parent().get_parent()
	player.velocity.y = JUMP_FORCE
	
func PhysicsUpdate(_delta: float):
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * speed
		player.velocity.z = direction.z * speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, speed)
		player.velocity.z = move_toward(player.velocity.z, 0, speed)
		
	if player.is_on_floor():
		Transitioned.emit(self, "idle")
