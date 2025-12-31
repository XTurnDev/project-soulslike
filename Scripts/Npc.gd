extends CharacterBody3D
class_name NpcBase

@export var npc_name: String = "NPC"
@onready var states: Node = $States

@onready var health_bar: ProgressBar = $Sprite3D/SubViewport/HealthBar

var current_state: State

var dialogue_text = {}

var is_shop: bool

var story_step: int = 0

signal hurt

var health: int = 100

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health

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

func GetHit(hit_damage: int, knockback_force: int):
	current_state = states.current_state
	if current_state.name == "death": return # Ölüye hasar verilemez
	
	health -= hit_damage
	health_bar.value -= hit_damage
	print("NPC Hasar Aldı! Kalan Can: ", health)
	
	# Hasar alınca NPC'yi 'HURT' (Hasar Alma) durumuna zorla
	#apply_knockback(knockback_force) # Geri itme uygula
	hurt.emit()

func Agro():
	pass

func Attack():
	pass
