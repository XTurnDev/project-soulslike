extends CharacterBody3D

const sensitivity = 0.01
@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var interactable_label: Label = $CanvasLayer/Hud/Interactable
@onready var weapon_hold_point: Node3D = $Head/Camera3D/right_arm/WeaponHoldPoint

const BASIC_SHORT_SWORD = preload("uid://bpq0w16q2ba72")
const WOOD_AXE = preload("uid://b1wr35ri455ei")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var instance = BASIC_SHORT_SWORD.instantiate()
	weapon_hold_point.add_child(instance)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if not target.is_in_group("Interactable"):
			return
		else:
			interactable_label.show()
	else:
		interactable_label.hide()
