extends RigidBody3D

@export var slot_data: SlotData

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.InPickUpRange(slot_data, self)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		body.OutPickUpRange()
