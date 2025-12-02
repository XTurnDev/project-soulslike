extends StaticBody3D

signal toggle_menu(external_inventory_owner)

@export var inventory_data: InventoryData

func player_interact() -> void:
	toggle_menu.emit(self)
