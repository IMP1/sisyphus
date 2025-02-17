extends Control
class_name SummaryScene

const PROVERBS: Array[String] = [
	"\"There is scarcely any passion without struggle.\"",
	"\"What is called a reason for living is also an excellent reason for dying.\"",
	"\"Existence is illusory and it is eternal.\"",
	"\"In order to understand the world, one has to turn away from it on occasion.\"",
]

@export var progress: GameProgress

@onready var _continue_btn := $Panel/Contents/Continue as Button
@onready var _title := $Panel/Contents/Title as Label
@onready var _time_played := $Panel/Contents/Stats/General/TimePlayed/Value as Label
@onready var _distance_travelled := $Panel/Contents/Stats/General/DistanceTravelled/Value as Label
@onready var _roll_attempts := $Panel/Contents/Stats/General/RollAttempts/Value as Label
@onready var _suicides := $Panel/Contents/Stats/General/Suicides/Value as Label
@onready var _spent_points := $Panel/Contents/Stats/Upgrades/SpentPoints/Value as Label
@onready var _unspent_points := $Panel/Contents/Stats/Upgrades/UnspentPoints/Value as Label
@onready var _unlocked_hats := $Panel/Contents/Stats/Unlocks/UnlockedHats/List as Control
@onready var _unlocked_specials := $Panel/Contents/Stats/Unlocks/UnlockedSpecials/List as Control
@onready var _boulder_size := $Panel/Contents/Stats/Boulder/Size/Value as Label
@onready var _hill_height := $Panel/Contents/Stats/Hill/Height/Value as Label
@onready var _hill_steepness := $Panel/Contents/Stats/Hill/Steepness/Value as Label
@onready var _sisyphus_strength := $Panel/Contents/Stats/Sisyphus/Strength/Value as Label
@onready var _sisyphus_speed := $Panel/Contents/Stats/Sisyphus/Speed/Value as Label
@onready var _sisyphus_contentedness := $Panel/Contents/Stats/Sisyphus/Contentedness/Value as Label


func _ready() -> void:
	_continue_btn.pressed.connect(_continue)
	_populate_stats()


func _continue() -> void:
	var scene := load("res://scenes/title.tscn") as PackedScene
	SceneTransition.change_scene_to_packed(scene)


func _populate_stats() -> void:
	_title.text = PROVERBS.pick_random() as String
	_time_played.text = "%.2f" % progress.time_played_seconds # TODO: Convert to a readable time
	_distance_travelled.text = "%.2f" % progress.distance_walked
	_roll_attempts.text = "%d" % progress.attempts
	_suicides.text = "%d" % progress.suicides
	_unspent_points.text = "%d" % progress.upgrade_points
	@warning_ignore("integer_division")
	_spent_points.text = "%d" % (floori(progress.attempts / 5) - progress.upgrade_points)
	_boulder_size.text = "%d" % progress.boulder_size
	_hill_height.text = "%d" % progress.hill_height
	_hill_steepness.text = "%d" % progress.hill_steepness
	_sisyphus_strength.text = "%d" % progress.sisyphus_strength
	_sisyphus_speed.text = "%d" % progress.sisyphus_speed
	_sisyphus_contentedness.text = "%d" % progress.sisyphus_contentedness
	for i in GameProgress.HAT_COUNT:
		var b := 1 << i
		if b & progress.sisyphus_unlocked_hats > 0:
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(32, 32)
			icon.texture = GameProgress.HAT_TEXTURES[i]
			_unlocked_hats.add_child(icon)
	for i in GameProgress.HILL_EXTRA_COUNT:
		var b := 1 << i
		if b & progress.hill_unlocked_extras > 0:
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(32, 32)
			icon.texture = GameProgress.HILL_EXTRA_TEXTURES[i]
			_unlocked_specials.add_child(icon)
