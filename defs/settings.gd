extends Resource
class_name UserSettings

const LANGUAGES: Array = [
	["en-GB", "English"],
	["es", "Español"],
	["ja", "日本語"],
	["el", "Νέα Ελληνικά"],
]

@export var audio_volume_master: float = 100.0
@export var audio_volume_music: float = 100.0
@export var audio_volume_sounds: float = 100.0

@export var language: int = 0

@export_range(0.0, 2.0) var screenshake_strength: float = 1.0

# TODO: Keybinds
