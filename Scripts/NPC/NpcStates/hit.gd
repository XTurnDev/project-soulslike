extends State

@export_category("Essentials")
@export var npc: CharacterBody3D
@export var damage_text: Label
@export var healthbar: ProgressBar

@onready var anim_timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var popup_timer: Timer = $"PopUpTimer"


var damage_taken: float
var knockback_force: float
var _player_pos: Vector3

func Enter():
	damage_taken = npc.damage_taken
	knockback_force = npc.knockback_force
	_player_pos = npc._player_pos

	animation_player.play("get_hit_loop")

	npc.health -= damage_taken
	healthbar.value -= damage_taken
	damage_text.text = str(damage_taken)
	damage_text.show()

	anim_timer.start()
	popup_timer.start()

	ApplyKnockback(knockback_force, _player_pos)

func ApplyKnockback(force: float, player_pos: Vector3) -> void:
	var direction = npc.global_position - player_pos
	direction.y = 0 
	var knockback_dir = direction.normalized()
	npc.velocity = knockback_dir * force

func _on_timer_timeout() -> void:
	if npc.health <= 0:
		Transitioned.emit(self, "death")
	else:
		Transitioned.emit(self, "idle")

func _on_popup_timer_timeout() -> void:
	damage_text.hide()
