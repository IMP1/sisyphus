extends Control

@export var background_music: AudioStream

@onready var _play_btn := $PanelContainer/Contents/Main/Actions/Play as Button
@onready var _settings_btn := $PanelContainer/Contents/Main/Actions/Settings as Button
@onready var _credits_btn := $PanelContainer/Contents/Main/Actions/Credits as Button
@onready var _quit_btn := $PanelContainer/Contents/Main/Actions/Quit as Button


func _ready() -> void:
	get_tree().paused = false
	if MusicManager.is_playing:
		MusicManager.blend_to(background_music, 2.0)
	else:
		MusicManager.play(background_music)
	_play_btn.pressed.connect(_play)
	_settings_btn.pressed.connect(_settings)
	_credits_btn.pressed.connect(_credits)
	_quit_btn.pressed.connect(_quit_to_desktop)
	_play_btn.grab_focus()


func _play() -> void:
	var scene := preload("res://scenes/game.tscn")
	get_tree().change_scene_to_packed(scene)


func _settings() -> void:
	var scene := preload("res://scenes/settings.tscn").instantiate() as SettingsScene
	add_child(scene)
	scene.close_requested.connect(func():
		remove_child(scene)
		scene.queue_free())


func _credits() -> void:
	#var scene := preload("res://scenes/credits.tscn")
	pass


func _quit_to_desktop() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
