extends Control

@export var background_music: AudioStream

@onready var _play_btn := $PanelContainer/Contents/Main/Actions/Play as Button
@onready var _settings_btn := $PanelContainer/Contents/Main/Actions/Settings as Button
@onready var _credits_btn := $PanelContainer/Contents/Main/Actions/Credits as Button
@onready var _quit_btn := $PanelContainer/Contents/Main/Actions/Quit as Button
@onready var _focus_sfx := $UIFocus as AudioStreamPlayer
@onready var _selection_sfx := $UISelect as AudioStreamPlayer


func _ready() -> void:
	get_tree().paused = false
	if MusicManager.is_playing:
		MusicManager.blend_to(background_music, 2.0)
	else:
		MusicManager.play(background_music)
	_play_btn.grab_focus()
	_play_btn.focus_entered.connect(_focus_sfx.play)
	_settings_btn.focus_entered.connect(_focus_sfx.play)
	_credits_btn.focus_entered.connect(_focus_sfx.play)
	_quit_btn.focus_entered.connect(_focus_sfx.play)
	_play_btn.mouse_entered.connect(_focus_sfx.play)
	_settings_btn.mouse_entered.connect(_focus_sfx.play)
	_credits_btn.mouse_entered.connect(_focus_sfx.play)
	_quit_btn.mouse_entered.connect(_focus_sfx.play)
	_play_btn.pressed.connect(_selection_sfx.play)
	_settings_btn.pressed.connect(_selection_sfx.play)
	_credits_btn.pressed.connect(_selection_sfx.play)
	_quit_btn.pressed.connect(_selection_sfx.play)
	_play_btn.pressed.connect(_play)
	_settings_btn.pressed.connect(_settings)
	_credits_btn.pressed.connect(_credits)
	_quit_btn.pressed.connect(_quit_to_desktop)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"DEBUG_delete_progress") and OS.has_feature("debug"):
		print("Deleting progress from %s" % GameScene.PROGRESS_FILENAME)
		var err := DirAccess.remove_absolute(GameScene.PROGRESS_FILENAME)
		if err != OK:
			push_error(error_string(err))


func _play() -> void:
	var scene := preload("res://scenes/game.tscn")
	SceneTransition.change_scene_to_packed(scene)


func _settings() -> void:
	var scene := preload("res://scenes/settings.tscn").instantiate() as SettingsScene
	SceneTransition.push_scene(scene)
	scene.close_requested.connect(SceneTransition.pop_scene) # TODO: Make a non-fade transition (swipe left)


func _credits() -> void:
	var scene := preload("res://scenes/credits.tscn").instantiate() as CreditsScene
	SceneTransition.push_scene(scene)
	scene.close_requested.connect(SceneTransition.pop_scene) # TODO: Make a non-fade transition (swipe up)


func _quit_to_desktop() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
