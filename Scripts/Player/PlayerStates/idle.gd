extends State
class_name PlayerIdle

const DECELERATION_RATE = 25

@onready var player: CharacterBody3D

func Enter():
	player = get_parent().get_parent()
	
func PhysicsUpdate(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_vector = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if Input.is_action_just_pressed("move_jump") and player.is_on_floor():
		Transitioned.emit(self, "jump")
	
	if input_vector.length_squared() > 0.01:
		Transitioned.emit(self, "movement")
		
	else:
		var brake_force = DECELERATION_RATE * delta
		
		player.velocity.x = move_toward(player.velocity.x, 0, brake_force)
		player.velocity.z = move_toward(player.velocity.z, 0, brake_force)
	
	
