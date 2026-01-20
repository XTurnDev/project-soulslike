extends State

@onready var npc: CharacterBody3D
@onready var timer: Timer = $Timer

@export var pick_up_object: PackedScene

var damage_taken: int

func Enter() -> void:
	npc = get_parent().get_parent()
	#ölme animasyonu gelecek
	timer.start()

func _on_timer_timeout() -> void:
	if npc.drop_slot_data:
		InstantiateItem(npc.drop_slot_data)
	npc.queue_free()

func InstantiateItem(item: SlotData) -> void:
	var instance = pick_up_object.instantiate()
	instance.global_transform = npc.global_transform
	instance.slot_data = item
	get_tree().current_scene.add_child(instance)
