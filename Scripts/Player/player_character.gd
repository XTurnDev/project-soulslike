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
var pickupable: bool = false

var lockable: bool = false
var locked_on: bool = false
var npc_near: Array[CharacterBody3D] = []
var current_lock_target: CharacterBody3D = null

var pick_up_object: Node3D
var pick_up_slot_data: SlotData

var in_menu: bool = false

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
		if not locked_on:
			rotate_y(-event.relative.x * sensitivity)
			camera.rotate_x(-event.relative.y * sensitivity)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if Input.is_action_just_pressed("action_interaction"):
		if interactable:
			if raycast.get_collider().has_method("interact"):
				raycast.get_collider().interact()
		if pickupable:
			if inventory_data.pick_up_slot_data(pick_up_slot_data):
				pick_up_object.queue_free()
	
	if Input.is_action_just_pressed("action_escape"):
		in_menu = !in_menu
		toggle_menu.emit()
	
	if Input.is_action_just_pressed("action_lockon"):
		if not lockable:
			return
		if not locked_on:
			locked_on = true
			LockOn()
		elif locked_on:
			locked_on = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()
	
	if locked_on and current_lock_target:
		# Hedef öldüyse veya silindiyse kilidi bırak
		if not is_instance_valid(current_lock_target):
			StopLockOn()
			return
			
		var target_pos = current_lock_target.global_position
		target_pos.y = global_position.y # Yükseklik farkını yok say, sadece yatay dön
		
		# Yumuşak dönüş (Slerp)
		var current_transform = global_transform
		var target_transform = current_transform.looking_at(target_pos, Vector3.UP)
		global_transform = current_transform.interpolate_with(target_transform, 10 * delta)
		
		var cam_target_pos = current_lock_target.global_position
		cam_target_pos.y += 1.5
		
		var cam_current_xform = camera.global_transform
		var cam_target_xform = cam_current_xform.looking_at(cam_target_pos, Vector3.UP)
		camera.global_transform = cam_current_xform.interpolate_with(cam_target_xform, 10 * delta)
	
	if raycast.is_colliding():
		var target = raycast.get_collider()
		if not target == null and not target.is_in_group("Interactable"):
			return
		if not interactable:
			interactable = true
			interactable_label.show()
	else:
		if interactable:
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

func LockOn() -> void:
	var closest_target = null
	var closest_dist = 9999.0
	
	for target in npc_near:
		if is_instance_valid(target):
			var dist = global_position.distance_to(target.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_target = target
	
	if closest_target:
		current_lock_target = closest_target
		locked_on = true

func StopLockOn() -> void:
	locked_on = false
	current_lock_target = null

func InPickUpRange(slot_data, item) -> void:
	pickupable = true
	pick_up_object = item
	pick_up_slot_data = slot_data
	interactable_label.show()

func OutPickUpRange() -> void:
	pickupable = false
	pick_up_object = null
	pick_up_slot_data = null
	interactable_label.hide()


func _on_lock_on_chamber_body_entered(body: Node3D) -> void:
	if body.is_in_group("npc"):
		if not npc_near.has(body):
			npc_near.append(body)
			lockable = true


func _on_lock_on_chamber_body_exited(body: Node3D) -> void:
	if body.is_in_group("npc"):
		lockable = false
		npc_near.append(body)
	
		if body == current_lock_target:
			StopLockOn()
			
		if npc_near.size() == 0:
			lockable = false
