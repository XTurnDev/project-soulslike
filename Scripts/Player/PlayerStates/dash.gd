extends State

var dash_speed: float = 15
var dash_time: float = 0.2

@onready var player: CharacterBody3D
@onready var timer: Timer = $DashTimer

@export var collision: CollisionShape3D

var input_dir
var input_vector
var direction

func _ready() -> void:
	player = get_parent().get_parent()

func Enter() -> void:
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	input_vector = Vector3(input_dir.x, 0, input_dir.y).normalized()
	if input_dir:
		dash_time = 0.3
		dash_speed = 15
	else:
		dash_time = 0.05
		dash_speed = 15
		dash_speed = dash_speed * 0.8
	timer.start(dash_time)
	collision.disabled = true

func PhysicsUpdate(_delta: float):
	if input_dir:
		direction = (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	else:
		direction = (player.transform.basis * Vector3.BACK).normalized()

	if direction:
		player.velocity.x = direction.x * dash_speed
		player.velocity.z = direction.z * dash_speed


func _on_dash_timer_timeout() -> void:
	collision.disabled = false
	Transitioned.emit(self, "idle")
