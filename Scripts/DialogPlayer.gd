extends Control

var dialog_data: Dictionary = {}
var selected_text: Array[String] = []

@export var dialog_panel: Control
@onready var text_label: Label = $DialogueBox/DialogueText
@onready var name_text: Label = $NameTag/NameText

var in_progress: bool = false

func _ready() -> void:
	SignalBus.display_dialog.connect(_on_signal_display)

func show_text() -> void:
	text_label.text = selected_text.pop_front()

func next_line() -> void:
	if selected_text.size() > 0:
		show_text()
	else:
		finish()

func finish() -> void:
	text_label.text = ""
	hide()
	in_progress = false
	get_tree().paused = false

func _on_signal_display(text_key, dialog, name) -> void:
	load_dialog_data(dialog)
	name_text.text = name
	if in_progress:
		next_line()
	else:
		get_tree().paused = true
		show()
		in_progress = true
		selected_text = dialog_data[text_key].duplicate()
		show_text()

func load_dialog_data(_dialog) -> void:
	var json_text = _dialog.get_as_text()
	var parsed_data = JSON.parse_string(json_text)

	if parsed_data is Dictionary:
		dialog_data = parsed_data
		print("json basariyla yuklendi")
	else:
		print("hata: json yuklenmedi")

