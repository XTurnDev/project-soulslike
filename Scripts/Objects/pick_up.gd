extends RigidBody3D

@export var slot_data: SlotData

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.inventory_data.pick_up_slot_data(slot_data):
		queue_free()
