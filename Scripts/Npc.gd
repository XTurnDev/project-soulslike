extends CharacterBody3D
class_name NpcBase

@export var npc_name: String = "NPC"

var dialogue_text = {}

var is_shop: bool

var story_step: int = 0

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()

func Interact():
	pass
	
func Shop():
	pass

func Die():
	pass

func GetHit():
	pass

func Agro():
	pass
	
func Attack():
	pass
