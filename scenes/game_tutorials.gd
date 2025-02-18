extends Node2D


func _ready() -> void:
	for child in get_children():
		child.visible = true

# TODO: Have a way to toggle different tutorial/input-prompts
#       Have this be self-contained as much as possible
