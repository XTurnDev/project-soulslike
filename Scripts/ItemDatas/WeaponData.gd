extends EquipData
class_name WeaponData

@export_group("Visual")
@export var mesh: PackedScene

@export_group("Stats")
@export var weapon_type: String
@export var damage: int
@export var attack_speed: float

@export_group("Hitbox")
@export var hitbox_size: Vector3 = Vector3(1, 1, 1) # Çarpışma kutusunun boyutu
@export var hitbox_offset: Vector3 = Vector3(0, 0, -1) # Kutusunun pozisyonu (Örn: Oyuncunun 1 metre önü)
