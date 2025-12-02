extends PanelContainer

const SLOT = preload("res://Scripts/Inventory/slot.tscn")

@onready var grid_container: GridContainer = $MarginContainer/GridContainer

func set_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.connect(populate_item_grid)
	populate_item_grid(inventory_data)

func clear_inventory_data(inventory_data: InventoryData) -> void:
	inventory_data.inventory_updated.disconnect(populate_item_grid)
	populate_item_grid(inventory_data)

func populate_item_grid(inventory_data: InventoryData) -> void:
	for child in grid_container.get_children():
		child.queue_free()
	
	for slot_data in inventory_data.slot_datas:
		var slot = SLOT.instantiate()
		grid_container.add_child(slot)
		
		slot.slot_clicked.connect(inventory_data.on_slot_clicked)
		
		if slot_data:
			slot.set_slot_data(slot_data)
