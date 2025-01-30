extends Control
class_name SummaryScene

@export var progress: GameProgress

@onready var _continue_btn := $Panel/Contents/Continue as Button


func _ready() -> void:
	_continue_btn.pressed.connect(_continue)
	_populate_stats()


func _continue() -> void:
	var scene := load("res://scenes/title.tscn") as PackedScene
	get_tree().change_scene_to_packed(scene)


func _populate_stats() -> void:
	pass
