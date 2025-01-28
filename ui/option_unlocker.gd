extends VBoxContainer
class_name OptionUnlocker

signal unlocked
signal toggled(state: bool)

@export var icon: Texture2D
@export var disabled: bool = false:
	set(value):
		disabled = value
		_unlock_button.disabled = value
@export var button_group: ButtonGroup

var is_unlocked: bool = false:
	set(value):
		is_unlocked = value
		_unlock_button.set_pressed_no_signal(value)
		_toggle_button.disabled = not value
var is_active: bool = false:
	set(value):
		is_active = value
		_toggle_button.button_pressed = value
	get():
		return _toggle_button.button_pressed

@onready var _unlock_button := $Unlock as Button
@onready var _toggle_button := $Activate as Button


func _ready() -> void:
	_unlock_button.icon = icon
	_toggle_button.button_group = button_group
	_toggle_button.disabled = true
	_unlock_button.pressed.connect(func(): 
		if is_unlocked:
			return
		is_unlocked = true
		_toggle_button.disabled = false
		unlocked.emit())
	_toggle_button.toggled.connect(toggled.emit)
