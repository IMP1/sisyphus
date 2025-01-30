extends Node2D
class_name GameScene

const PROGRESS_FILENAME := "user://progress.tres"

@export var background_music: AudioStream
@export var progress: GameProgress

@export_category("References")
@export var player: Player
@export var player_spawn: Marker2D
@export var boulder_spawn: Marker2D
@export var boulder: Boulder
@export var pit: Area2D
@export var pit_top: Area2D
@export var hilltop: Area2D
@export var camera: ShakeableCamera2D

var _is_rolling_boulder: bool = false
var _upgrade_queue: Array = []

@onready var _falling_sound := $FallingSound as AudioStreamPlayer
@onready var _thump_sound := $PlayerSpawn/ThumpSound as AudioStreamPlayer2D
@onready var _gui_container := $GUI as CanvasLayer
@onready var _gui_progress_label := $GUI/Progress/Panel/Contents/Value as Button
@onready var _gui_progress_bar := $GUI/Progress/Panel/Contents/ProgressBar as TextureProgressBar
@onready var _gui_upgrade_shop := $GUI/UpgradeShop as UpgradeShop
@onready var _gui_menu_open_btn := $GUI/Menu/Button as Button
@onready var _gui_menu := $GUI/Menu/Modal as Control
@onready var _gui_menu_resume_btn := $GUI/Menu/Modal/PanelContainer/VBoxContainer/Resume as Button
@onready var _gui_menu_give_up_btn := $GUI/Menu/Modal/PanelContainer/VBoxContainer/GiveUp as Button
@onready var _gui_menu_setttings_btn := $GUI/Menu/Modal/PanelContainer/VBoxContainer/Settings as Button
@onready var _gui_menu_quit_btn := $GUI/Menu/Modal/PanelContainer/VBoxContainer/Quit as Button
@onready var _gui_quit_confirmation := $QuitConfirmation as PopupPanel
@onready var _gui_quit_to_title := $QuitConfirmation/Panel/VBoxContainer/QuitTitle as Button
@onready var _gui_quit_to_desktop := $QuitConfirmation/Panel/VBoxContainer/QuitDesktop as Button
@onready var _gui_quit_cancel := $QuitConfirmation/Panel/VBoxContainer/Cancel as Button


func _ready() -> void:
	if MusicManager.is_playing:
		MusicManager.blend_to(background_music, 2.0)
	else:
		MusicManager.play(background_music)
	if ResourceLoader.exists(PROGRESS_FILENAME):
		print("Loading progress from %s" % PROGRESS_FILENAME)
		progress = ResourceLoader.load(PROGRESS_FILENAME) as GameProgress
	else:
		progress = GameProgress.new()
	_gui_upgrade_shop.visible = false
	_gui_upgrade_shop.progress = progress
	_gui_quit_confirmation.hide()
	_gui_menu.visible = false
	pit.body_entered.connect(_revive_player)
	pit.body_entered.connect(func(_node): progress.suicides += 1)
	pit_top.body_entered.connect(_start_player_falling)
	hilltop.body_entered.connect(_roll_boulder)
	player.stopped_pushing.connect(boulder.push.bind(Vector2.ZERO))
	player.moved.connect(func(distance: Vector2):
		progress.distance_walked += distance.length())
	boulder.started_moving.connect(func():
		camera.add_screen_rumble(Vector2(0.5, 0.5)))
	boulder.stopped_moving.connect(func():
		camera.add_screen_rumble(Vector2(-0.5, -0.5)))
	_gui_menu_open_btn.pressed.connect(_open_menu)
	_gui_menu_resume_btn.pressed.connect(_close_menu)
	_gui_progress_label.pressed.connect(_offer_upgrade)
	_gui_menu_give_up_btn.pressed.connect(_game_over)
	_gui_menu_setttings_btn.pressed.connect(_open_settings)
	_gui_menu_quit_btn.pressed.connect(_quit)
	_gui_upgrade_shop.upgrade_chosen.connect(_queue_upgrade)
	_gui_upgrade_shop.close_requested.connect(_close_upgrade_shop)
	_gui_quit_to_title.pressed.connect(_quit_to_title.call_deferred)
	_gui_quit_to_desktop.pressed.connect(_quit_to_desktop.call_deferred)
	_gui_quit_cancel.pressed.connect(_gui_quit_confirmation.hide)
	SettingsManager.settings_changed.connect(func():
		camera.shake_strength_modifier = SettingsManager.settings.screenshake_strength)
	_reset_player()
	_refresh_progress_gui()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"DEBUG_increase_attempts"):
		_increase_attempts()


func _reset_player() -> void:
	player.velocity = Vector2.ZERO
	player.position = player_spawn.position


func _start_player_falling(_player: Player) -> void:
	_falling_sound.volume_db = -80.0
	_falling_sound.play()
	var tween := create_tween()
	tween.tween_property(_falling_sound, "volume_db", 0.0, 1.0).set_trans(Tween.TRANS_EXPO)


func _revive_player(_player: Player) -> void:
	_player.position = player_spawn.position + Vector2.UP * 96
	_falling_sound.stop()
	_thump_sound.play()


func _roll_boulder(_boulder: Boulder) -> void:
	boulder.is_ignoring_player = true
	boulder.push_direction = Vector2.ZERO
	await get_tree().physics_frame
	boulder.ignore_player_contact()
	await _move_boulder_towards_spawn()
	boulder._wait_for_reset()
	_increase_attempts()


func _increase_attempts() -> void:
	progress.attempts += 1
	if progress.attempts % int(_gui_progress_bar.max_value) == 0:
		progress.upgrade_points += 1
		_offer_upgrade()
	_refresh_progress_gui()


func _refresh_progress_gui() -> void:
	_gui_progress_label.text = str(progress.attempts)
	_gui_progress_bar.value = progress.attempts % int(_gui_progress_bar.max_value)


func _offer_upgrade() -> void:
	_upgrade_queue.clear()
	_gui_upgrade_shop.refresh()
	_gui_upgrade_shop.visible = true
	_gui_upgrade_shop.grab_focus()
	get_tree().paused = true


func _queue_upgrade(upgrade: StringName) -> void:
	_upgrade_queue.append(upgrade)


func _close_upgrade_shop() -> void:
	_gui_upgrade_shop.visible = false
	get_tree().paused = false
	if _upgrade_queue.is_empty():
		return
	player.process_mode = Node.PROCESS_MODE_DISABLED
	camera.process_mode = Node.PROCESS_MODE_ALWAYS
	for upgrade in _upgrade_queue:
		print(upgrade)
		await get_tree().create_timer(0.4).timeout
		if (upgrade as StringName).begins_with("sisyphus_"):
			var animation := AnimatedSprite2D.new()
			add_child(animation)
			animation.sprite_frames = load("res://assets/player_growth.aseprite")
			animation.position = player.position + Vector2(2, -15) # TODO: De-magic these numbers (player sprite relative to player position)
			animation.modulate = Color("eec39a")
			animation.play(&"spark")
			# TODO: Play a fanfare or something?
			camera.add_screen_shake_constant(0.3, Vector2(4, 2))
			await animation.animation_looped
			animation.stop()
			remove_child(animation)
			animation.queue_free()
	# TODO: Process queued upgrades and then animate them when closing the shop
	# TODO: Have updates change the game world
	player.process_mode = Node.PROCESS_MODE_INHERIT
	camera.process_mode = Node.PROCESS_MODE_INHERIT


func _open_menu() -> void:
	_gui_menu.visible = true
	_gui_menu_resume_btn.grab_focus()
	get_tree().paused = true


func _close_menu() -> void:
	get_tree().paused = false
	_gui_menu.visible = false


func _move_boulder_towards_spawn() -> void:
	boulder.push_direction = Vector2.ZERO
	boulder.get_node(^"Debug/States/RollingBack").visible = true
	_is_rolling_boulder = true
	while boulder.position.x > boulder_spawn.position.x:
		await get_tree().process_frame
	_is_rolling_boulder = false
	boulder.get_node(^"Debug/States/RollingBack").visible = false
	boulder.push_direction = Vector2.ZERO


func _process(delta: float) -> void:
	progress.time_played_seconds += delta
	if _is_rolling_boulder:
		boulder.push_direction += Vector2(-1, 0.5) * 24 * delta
		if boulder.position.y > -2:
			boulder.push_direction *= pow(0.4, delta)
			boulder.get_node(^"Debug/States/SlowingDown").visible = true
	else:
		boulder.get_node(^"Debug/States/SlowingDown").visible = false


func _game_over() -> void:
	var scene := preload("res://scenes/summary.tscn").instantiate() as SummaryScene
	scene.progress = progress
	print("Deleting progress from %s" % PROGRESS_FILENAME)
	DirAccess.remove_absolute(PROGRESS_FILENAME)
	get_tree().root.add_child(scene)
	get_tree().root.remove_child(self)


func _open_settings() -> void:
	var settings := preload("res://scenes/settings.tscn").instantiate() as SettingsScene
	_gui_container.add_child(settings)
	settings.close_requested.connect(func():
		_gui_container.remove_child(settings)
		settings.queue_free())


func _save_progress() -> void:
	print("Saving progress to %s" % PROGRESS_FILENAME)
	ResourceSaver.save(progress, PROGRESS_FILENAME)


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_progress()


func _quit() -> void:
	_gui_quit_confirmation.show()
	_gui_quit_to_title.grab_focus()


func _quit_to_title() -> void:
	_save_progress()
	var scene := load("res://scenes/title.tscn") as PackedScene
	get_tree().change_scene_to_packed(scene)


func _quit_to_desktop() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
