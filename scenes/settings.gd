extends Control
class_name SettingsScene

signal close_requested

@onready var _close_btn := $PanelContainer/VBoxContainer/Close as Button
@onready var _audio_master := $PanelContainer/VBoxContainer/HBoxContainer/Audio/MasterVolume/HSlider as HSlider
@onready var _audio_music := $PanelContainer/VBoxContainer/HBoxContainer/Audio/MusicVolume/HSlider as HSlider
@onready var _audio_sfx := $PanelContainer/VBoxContainer/HBoxContainer/Audio/SoundsVolume/HSlider as HSlider
@onready var _language := $PanelContainer/VBoxContainer/HBoxContainer/General/Language/OptionButton as OptionButton
@onready var _screenshake := $PanelContainer/VBoxContainer/HBoxContainer/General/Screenshake/HSlider as HSlider


func _ready() -> void:
	_close_btn.pressed.connect(close_requested.emit)
	_audio_master.value_changed.connect(func(value: float):
		SettingsManager.settings.audio_volume_master = value
		SettingsManager.settings.emit_changed())
	_audio_music.value_changed.connect(func(value: float):
		SettingsManager.settings.audio_volume_music = value
		SettingsManager.settings.emit_changed())
	_audio_sfx.value_changed.connect(func(value: float):
		SettingsManager.settings.audio_volume_sounds = value
		SettingsManager.settings.emit_changed())
	_language.item_selected.connect(func(index: int):
		SettingsManager.settings.language = index
		SettingsManager.settings.emit_changed())
	_screenshake.value_changed.connect(func(value: float):
		SettingsManager.settings.screenshake_strength = value
		SettingsManager.settings.emit_changed())
	for language in UserSettings.LANGUAGES:
		_language.add_item(language[1])
	
	_audio_master.value = SettingsManager.settings.audio_volume_master
	_audio_music.value = SettingsManager.settings.audio_volume_music
	_audio_sfx.value = SettingsManager.settings.audio_volume_sounds
	_language.select(SettingsManager.settings.language)
	_screenshake.set_value_no_signal(SettingsManager.settings.screenshake_strength)
	# TODO: Set up keybindings
