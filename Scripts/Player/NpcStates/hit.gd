extends State

@onready var npc: CharacterBody3D
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"

var damage_taken: int

func Enter():
	npc = get_parent().get_parent()
	animation_player.play("get_hit_loop")
	npc.health -= damage_taken
	timer.start()


func _on_timer_timeout() -> void:
	if npc.health < 0:
		Transitioned.emit(self, "death")
	else:
		Transitioned.emit(self, "idle")
