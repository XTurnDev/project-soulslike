extends State

const JUMP_FORCE: float = 5

@onready var player: CharacterBody3D

func Enter():
	player = get_parent().get_parent()
	player.velocity.y = JUMP_FORCE
	
func PhysicsUpdate(_delta: float):
	if player.is_on_floor():
		Transitioned.emit(self, "idle")
