extends State

const DECELERATION_RATE = 25

@export var weapon_hitbox: Area3D
@export var right_arm: Node3D
@export var attack_timer: Timer
@export var heavy_attack_charge: Timer

var current_damage: float
var attack_speed: float
var weapon_type: String
var knockback_force: int
var heavy_attack_charge_time: float

var light_damage: float = 10.0
var heavy_damage: float = 25.0
var light_speed: float = 0.4
var heavy_speed: float = 0.8

var attack_number: int

var next_attack_request: String = ""

var in_anim: bool = false

var hitbox_col: CollisionShape3D
@onready var player: CharacterBody3D

var attack_type: String = ""
var item_data: ItemData

func _ready():
	player = get_parent().get_parent()
	hitbox_col = $"../../Head/Camera3D/Hitboxes/DefaultHitbox/CollisionShape3D"

func Enter() -> void:
	var slot_data = player.right_hand_inventory_data.slot_datas[0]
	if not slot_data or not slot_data.item_data:
		Transitioned.emit(self, "idle")
		return
	
	item_data = slot_data.item_data
	
	weapon_type = item_data.weapon_type
	light_damage = item_data.damage
	heavy_damage = light_damage * 1.5
	knockback_force = item_data.knockback
	
	attack_speed = item_data.attack_speed
	
	attack_timer.wait_time = attack_speed
	
	attack_type = player.intended_attack_type
	
	if attack_type == "light":
		current_damage = light_damage
		attack_timer.wait_time = light_speed
		# player.anim_player.play("light_attack_" + str(attack_number % 2))
		hitbox_col.disabled = false
		attack_timer.start()
	elif attack_type == "heavy":
		heavy_attack_charge.start(item_data.charge_time)
		# player.anim_player.play("heavy_attack")
	in_anim = true
	
	next_attack_request = ""

func PhysicsUpdate(_delta: float) -> void:
	var brake_force = DECELERATION_RATE * _delta
	
	player.velocity.x = move_toward(player.velocity.x, 0, brake_force)
	player.velocity.z = move_toward(player.velocity.z, 0, brake_force)

	if attack_type == "heavy":
		if Input.is_action_just_released("action_heavy_attack"):
			heavy_damage *= (1 + (item_data.charge_time - heavy_attack_charge.time_left) * 0.5)
			heavy_attack_charge.stop()
			current_damage = heavy_damage
			attack_timer.wait_time = heavy_speed
			hitbox_col.disabled = false
			attack_timer.start()

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
			Transitioned.emit(self, "dash")
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

func on_charge_timer_timeout() -> void:
	heavy_damage *= (1 + (item_data.charge_time - heavy_attack_charge.time_left) * 0.5)
	current_damage = heavy_damage
	attack_timer.wait_time = heavy_speed
	hitbox_col.disabled = false
	attack_timer.start()

func _on_default_hitbox_entered(area: Area3D) -> void:
	var body = area.get_parent()
	if body.is_in_group("npc"):
		print(current_damage)
		body.GetHit(current_damage, knockback_force, player.global_position)
