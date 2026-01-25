extends State

const DECELERATION_RATE = 25

@onready var npc: CharacterBody3D

func Enter():
	npc = get_parent().get_parent()
	

func PhysicsUpdate(_delta: float):
	var brake_force = DECELERATION_RATE * _delta
		
	npc.velocity.x = move_toward(npc.velocity.x, 0, brake_force)
	npc.velocity.z = move_toward(npc.velocity.z, 0, brake_force)

