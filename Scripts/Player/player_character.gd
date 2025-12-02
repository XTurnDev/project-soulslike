extends CharacterBody3D

signal toggle_menu


@export var inventory_data: InventoryData
@export var equip_inventory_data: InventoryDataEquip

const sensitivity = 0.001
@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var interactable_label: Label = $CanvasLayer/Hud/Interactable
@onready var weapon_hold_point: Node3D = $Head/Camera3D/right_arm/WeaponHoldPoint

@onready var hitbox_col_shape = $Head/Camera3D/Hitboxes/Area3D/CollisionShape3D
@onready var hitbox_area = $Head/Camera3D/Hitboxes/Area3D

var health: int = 100

var interactable: bool = false

func _ready():
	PlayerManager.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if Input.is_action_just_pressed("action_interaction"):
		if interactable:
			if raycast.get_collider().has_method("player_interact"):
				raycast.get_collider().player_interact()
	
	if Input.is_action_just_pressed("action_escape"):
		toggle_menu.emit()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if not target.is_in_group("Interactable"):
			return
		else:
			interactable = true
			interactable_label.show()
	else:
		interactable = false
		interactable_label.hide()

func equip_weapon(data: WeaponData):
	# Eski silah modelini sil
	for child in weapon_hold_point.get_children():
		child.queue_free()
	
	# Yeni .blend sahnesini oluştur (Instantiate)
	if data.mesh:
		var new_weapon = data.mesh.instantiate()
		weapon_hold_point.add_child(new_weapon)
	else:
		print("No Mesh")
	
	# Resource dosyasından gelen boyut verisini uygula
	hitbox_col_shape.shape.size = data.hitbox_size
	
	# Pozisyonu güncelle (Silahın menziline göre kutuyu ileri/geri al)
	hitbox_col_shape.position = data.hitbox_offset
	
	print(data.name + " kuşandı. Hitbox boyutu güncellendi: " + str(data.hitbox_size))

func get_drop_position() -> Vector3:
	var direction = -camera.global_transform.basis.z
	return camera.global_position + direction

func heal(heal_value: int) -> void:
	health += heal_value
