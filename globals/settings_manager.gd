extends Node

const AUDIO_BUS_MASTER := 0
const AUDIO_BUS_SOUNDS := 1
const AUDIO_BUS_MUSIC := 2

const SETTINGS_FILEPATH := "user://user_settings.tres"

var settings: UserSettings


func _ready() -> void:
	if ResourceLoader.exists(SETTINGS_FILEPATH):
		_load_settings()
	else:
		settings = UserSettings.new()
	settings.changed.connect(apply_settings)
	apply_settings()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_settings()


func _load_settings() -> void:
	print("Loading settings from %s" % SETTINGS_FILEPATH)
	settings = ResourceLoader.load(SETTINGS_FILEPATH) as UserSettings


func _save_settings() -> void:
	print("Saving settings to %s" % SETTINGS_FILEPATH)
	ResourceSaver.save(settings, SETTINGS_FILEPATH)


func apply_settings() -> void:
	AudioServer.set_bus_volume_db(AUDIO_BUS_MASTER, linear_to_db(settings.audio_volume_master / 100.0))
	AudioServer.set_bus_volume_db(AUDIO_BUS_SOUNDS, linear_to_db(settings.audio_volume_sounds / 100.0))
	AudioServer.set_bus_volume_db(AUDIO_BUS_MUSIC, linear_to_db(settings.audio_volume_music / 100.0))
	TranslationServer.set_locale(UserSettings.LANGUAGES[settings.language][0])
