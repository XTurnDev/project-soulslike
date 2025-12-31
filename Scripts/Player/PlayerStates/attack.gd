extends State

@export var weapon_hitbox: Area3D
@export var right_arm: Node3D
@export var attack_timer: Timer

var current_damage: float
var attack_speed: float
var weapon_type: String

var light_damage: float = 10.0
var heavy_damage: float = 25.0
var light_speed: float = 0.4
var heavy_speed: float = 0.8

var attack_number: int

var next_attack_request: String = ""

var in_anim: bool = false

var hitbox_col: CollisionShape3D
@onready var player: CharacterBody3D

func _ready():
	# Player'ı en başta bulalım, her enter'da aramayalım (Performans)
	player = get_parent().get_parent()
	hitbox_col = $"../../Head/Camera3D/Hitboxes/DefaultHitbox/CollisionShape3D"

func Enter() -> void:
	var slot_data = player.right_hand_inventory_data.slot_datas[0]
	
	# Slot boş mu veya içinde item var mı kontrolü
	if not slot_data or not slot_data.item_data:
		Transitioned.emit(self, "idle") # Silah yoksa geri dön
		return
		
	var item_data = slot_data.item_data
	weapon_type = item_data.weapon_type
	var attack_type = player.intended_attack_type
	if attack_type == "light":
		current_damage = light_damage
		attack_timer.wait_time = light_speed
		# Burada animasyonu da tetikleyebilirsin
		# player.anim_player.play("light_attack_" + str(attack_number % 2))
	elif attack_type == "heavy":
		current_damage = heavy_damage
		attack_timer.wait_time = heavy_speed
		# player.anim_player.play("heavy_attack")
	hitbox_col.disabled = false
	attack_timer.start()
	in_anim = true
	
	next_attack_request = ""

func PhysicsUpdate(_delta: float) -> void:
	if attack_number > 3:
		attack_number = 0
	if in_anim and attack_timer.time_left < 0.5:
		if Input.is_action_just_pressed("action_light_attack"):
			next_attack_request = "light"
		elif Input.is_action_just_pressed("action_heavy_attack"):
			next_attack_request = "heavy"
	if Input.is_action_just_pressed("action_dash"):
		if in_anim:
			next_attack_request = ""
			# Dash state'ine geçiş ekleyebilirsin
			return
	if not in_anim:
		if next_attack_request != "":
			player.intended_attack_type = next_attack_request
			attack_number += 1
			Transitioned.emit(self, "attack")
		else:
			attack_number = 0
			Transitioned.emit(self, "idle")

func Exit() -> void:
	hitbox_col.disabled = true
	in_anim = false


func _on_timer_timeout() -> void:
	in_anim = false


func _on_default_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("npc"):
		body.GetHit(current_damage, 1)
