extends StaticBody3D

signal toggle_menu(external_inventory_owner)

@export var inventory_data: InventoryData
@export var mesh: Node3D
@export var timer: Timer

var is_open: bool = false
var can_open: bool = true

func interact() -> void:
	if !can_open: return
	toggle_menu.emit(self)
	is_open = true
	if is_open:
		mesh.get_child(2).play("ArmatureAction")
		timer.start(1.5)
		can_open = false

func _on_timer_timeout() -> void:
	can_open = true

func close() -> void:
	if is_open:
		mesh.get_child(2).play("ArmatureAction_002")
		is_open = false

