extends StaticBody3D

signal toggle_menu(external_inventory_owner)

@export var inventory_data: InventoryData

func interact() -> void:
	toggle_menu.emit(self)
