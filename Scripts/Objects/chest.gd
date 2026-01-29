extends StaticBody3D

signal toggle_menu(external_inventory_owner)

@export var inventory_data: InventoryData
@export var mesh: Node3D
@export var timer: Timer

var is_open: bool = false
var can_open: bool = true

func interact() -> void:
	if !can_open: return
	if is_open:
		close()
	else:
		open()

func open() -> void:
	toggle_menu.emit(self)
	mesh.get_child(2).play("ArmatureAction")
	timer.start(1.5)
	can_open = false
	is_open = true

func _on_timer_timeout() -> void:
	can_open = true

func close() -> void:
	mesh.get_child(2).play("ArmatureAction_002")
	timer.start(1.5)
	can_open = false
	is_open = false
	toggle_menu.emit(self)

