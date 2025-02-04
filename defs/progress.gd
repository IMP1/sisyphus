extends Resource
class_name GameProgress

const HAT_COUNT := 4
const HILL_EXTRA_COUNT := 2

const HAT_TEXTURES: Array[Texture2D] = [
	preload("res://assets/icons/chef-toque.svg"),
	preload("res://assets/icons/fez.svg"),
	preload("res://assets/icons/sombrero.svg"),
	preload("res://assets/icons/top-hat.svg"),
]
const HILL_EXTRA_TEXTURES: Array[Texture2D] = [
	preload("res://assets/icons/hand-of-god.svg"),
	preload("res://assets/icons/party-popper.svg"),
]

@export var attempts: int = 0
@export var upgrade_points: int = 0
@export var suicides: int = 0
@export var time_played_seconds: float = 0
@export var distance_walked: float = 0

@export var hill_height: int = 0
@export var hill_steepness: int = 0
@export_flags("God Taunts", "Confetti") var hill_unlocked_extras: int = 0
@export_flags("God Taunts", "Confetti") var hill_active_extras: int = 0

@export var sisyphus_speed: int = 0
@export var sisyphus_strength: int = 0
@export var sisyphus_contentedness: int = 0
@export_flags("Chef's Hat", "Fez", "Sombrero", "Top Hat") var sisyphus_unlocked_hats: int = 0
@export var sisyphus_current_hats: int = 0

@export var boulder_size: int = 0

@export var sisyphus_position: Vector2
@export var boulder_position: Vector2
