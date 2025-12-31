extends CharacterBody3D

signal toggle_menu

@export var inventory_data: InventoryData
@export var right_hand_inventory_data: InventoryDataEquip
@export var left_hand_inventory_data: InventoryDataEquip
@export var armor_inventory_data: InventoryDataEquip

const sensitivity = 0.001
@onready var head = $Head
@onready var camera = $Head/Camera3D

@onready var raycast: RayCast3D = $Head/Camera3D/RayCast3D
@onready var interactable_label: Label = $CanvasLayer/Hud/Interactable
@onready var weapon_hold_point: Node3D = $Head/Camera3D/right_arm/WeaponHoldPoint

@onready var hitbox_col_shape = $Head/Camera3D/Hitboxes/DefaultHitbox/CollisionShape3D
@onready var hitbox_area = $Head/Camera3D/Hitboxes/DefaultHitbox

var intended_attack_type: String = "light"

var health: int = 100

var interactable: bool = false

func _ready():
	PlayerManager.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	right_hand_inventory_data.inventory_updated.connect(update_right_hand_visuals)

func update_right_hand_visuals(_inventory_data: InventoryData) -> void:
	# Sağ el slotundaki ilk itemi al (zaten tek slot var)
	var slot_data = right_hand_inventory_data.slot_datas[0]
	
	# Önce eldeki eski silahı temizle
	for child in weapon_hold_point.get_children():
		child.queue_free()
	
	# Eğer slot boşsa fonksiyondan çık (silahı kaldırmış olduk)
	if not slot_data:
		return
		
	var item_data = slot_data.item_data
	if not item_data is WeaponData: # Sadece silahsa model oluştur
		return
		
	# Yeni modeli oluştur
	if item_data.mesh:
		var new_weapon = item_data.mesh.instantiate()
		weapon_hold_point.add_child(new_weapon)
		
		# Hitbox ayarları
		hitbox_col_shape.shape.size = item_data.hitbox_size
		hitbox_col_shape.position = item_data.hitbox_offset

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if Input.is_action_just_pressed("action_interaction"):
		if interactable:
			if raycast.get_collider().has_method("interact"):
				raycast.get_collider().interact()
	
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
