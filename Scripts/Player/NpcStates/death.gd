extends State

@onready var npc: CharacterBody3D
@onready var timer: Timer = $Timer

var damage_taken: int

func Enter():
	npc = get_parent().get_parent()
	#animasyon gelecek
	timer.start()
