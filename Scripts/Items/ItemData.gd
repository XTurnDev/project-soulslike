extends Resource
class_name ItemData

const DEBUG_ICON = preload("uid://b5v67mplxqd7j")

@export_category("Info")
@export var name: String = ""
@export_multiline var desc: String = ""

@export var stackable: bool = false
@export var icon: Texture = DEBUG_ICON
@export var item_type: String = ""
