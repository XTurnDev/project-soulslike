extends Node3D

const PICK_UP = preload("uid://cq3vuh1t3v45b")

@onready var player_character: CharacterBody3D = $PlayerCharacter
@onready var inventory_interface: Control = $CanvasLayer/InventoryInterface
@onready var hot_bar_inventory: PanelContainer = $CanvasLayer/HotBarInventory

func _ready() -> void:
	player_character.toggle_menu.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player_character.inventory_data)
	
	inventory_interface.set_player_equip_data(
		player_character.right_hand_inventory_data,
		player_character.left_hand_inventory_data,
		player_character.armor_inventory_data)
	
	inventory_interface.force_close.connect(toggle_inventory_interface)
	hot_bar_inventory.set_inventory_data(player_character.inventory_data)
	
	for node in get_tree().get_nodes_in_group("external_inventory"):
		node.toggle_menu.connect(toggle_inventory_interface)

func toggle_inventory_interface(external_inventory_owner = null) -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		hot_bar_inventory.hide()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		hot_bar_inventory.show()
	
	if external_inventory_owner and inventory_interface.visible:
		inventory_interface.set_external_inventory(external_inventory_owner)
	else:
		inventory_interface.clear_external_inventory()


func _on_inventory_interface_drop_slot_data(slot_data: SlotData) -> void:
	var pick_up = PICK_UP.instantiate()
	pick_up.slot_data = slot_data
	pick_up.position = player_character.get_drop_position()
	add_child(pick_up)
