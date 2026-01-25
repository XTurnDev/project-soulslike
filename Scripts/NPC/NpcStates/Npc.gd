extends CharacterBody3D
class_name NpcBase

@export var npc_name: String = "NPC"
@onready var states: Node = $States

@export var loot_item: ItemData 
@export var loot_quantity: int = 1

@export var hostile: bool
@export var talkable: bool

@onready var health_bar: ProgressBar = $"2DVisuals/SubViewport/HealthBar"
@onready var name_label: Label = $"2DVisuals/SubViewport/NpcName"
@export var friction: float = 10.0

var current_state: State

var is_shop: bool

var story_step: int = 0

var health: int = 100

var drop_slot_data: SlotData

var dialogue_key: String = ""

var damage_taken: float = 0
var knockback_force: float
var _player_pos: Vector3

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health
	name_label.text = npc_name
	if loot_item:
		drop_slot_data = SlotData.new()
		drop_slot_data.item_data = loot_item
		drop_slot_data.quantity = loot_quantity

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor():
		velocity.x = move_toward(velocity.x, 0, friction * delta)
		velocity.z = move_toward(velocity.z, 0, friction * delta)
	
	move_and_slide()

func interact():
	if talkable:
		SignalBus.emit_signal("display_dialog", dialogue_key)

func Shop():
	pass

func Die():
	pass

func GetHit(hit_damage: int, _knockback_force: int, player_pos: Vector3):
	damage_taken = hit_damage
	knockback_force = _knockback_force
	_player_pos = player_pos
	states.current_state.Transitioned.emit(states.current_state, "hit")

func Agro():
	pass

func Attack():
	pass
