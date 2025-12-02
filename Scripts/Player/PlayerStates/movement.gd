extends State

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0

const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

@onready var head: Node3D
@onready var camera: Camera3D

@onready var player: CharacterBody3D

func Enter():
	player = get_parent().get_parent()
	head = player.find_child("Head")
	camera = head.find_child("Camera3D")

func PhysicsUpdate(_delta: float):
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var input_vector = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if Input.is_action_pressed("move_jump"):
		Transitioned.emit(self, "jump")
	
	if Input.is_action_pressed("action_sprint"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED
	
	if input_vector.length_squared() > 0.01:
		
		
		var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			player.velocity.x = direction.x * speed
			player.velocity.z = direction.z * speed
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, speed)
			player.velocity.z = move_toward(player.velocity.z, 0, speed)
	
	else:
		Transitioned.emit(self, "idle")
	
	t_bob += _delta * player.velocity.length() * float(player.is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	var velocity_clamped = clamp(player.velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, _delta * 8.0)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
