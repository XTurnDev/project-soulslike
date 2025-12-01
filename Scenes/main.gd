extends Node3D

@onready var player_character: CharacterBody3D = $PlayerCharacter
@onready var inventory_interface: Control = $CanvasLayer/InventoryInterface

func _ready() -> void:
	player_character.toggle_menu.connect(toggle_inventory_interface)
	inventory_interface.set_player_inventory_data(player_character.inventory_data)

func toggle_inventory_interface() -> void:
	inventory_interface.visible = not inventory_interface.visible
	
	if inventory_interface.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
