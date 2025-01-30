extends Control
class_name UpgradeShop

signal close_requested
signal upgrade_chosen(upgrade: StringName)

@export var progress: GameProgress

@onready var _close_button := $Panel/Close as Button
@onready var _upgrade_points := $Panel/Contents/AvailablePoints as Label
@onready var _upgrade_sisyphus_strength := $Panel/Contents/Upgrades/Sisyphus/Strength/Button as Button
@onready var _upgrade_sisyphus_speed := $Panel/Contents/Upgrades/Sisyphus/Speed/Button as Button
@onready var _upgrade_sisyphus_contentedness := $Panel/Contents/Upgrades/Sisyphus/Contentedness/Button as Button
@onready var _upgrade_boulder_size := $Panel/Contents/Upgrades/Boulder/Size/Button as Button
@onready var _upgrade_hill_height := $Panel/Contents/Upgrades/Hill/Height/Button as Button
@onready var _upgrade_hill_steepness := $Panel/Contents/Upgrades/Hill/Steepness/Button as Button
@onready var _upgrade_hat_list := $Panel/Contents/Upgrades/Sisyphus/Hats/List as Control
@onready var _upgrade_special_list := $Panel/Contents/Upgrades/Hill/Special/List as Control
@onready var _sisyphus_strength := $Panel/Contents/Upgrades/Sisyphus/Strength/Value as Label
@onready var _sisyphus_speed := $Panel/Contents/Upgrades/Sisyphus/Speed/Value as Label
@onready var _sisyphus_contentedness := $Panel/Contents/Upgrades/Sisyphus/Contentedness/Value as Label
@onready var _boulder_size := $Panel/Contents/Upgrades/Boulder/Size/Value as Label
@onready var _hill_height := $Panel/Contents/Upgrades/Hill/Height/Value as Label
@onready var _hill_steepness := $Panel/Contents/Upgrades/Hill/Steepness/Value as Label


func _ready() -> void:
	_close_button.pressed.connect(close_requested.emit)
	_upgrade_sisyphus_strength.pressed.connect(_increase_stat.bind(&"sisyphus_strength"))
	_upgrade_sisyphus_speed.pressed.connect(_increase_stat.bind(&"sisyphus_speed"))
	_upgrade_sisyphus_contentedness.pressed.connect(_increase_stat.bind(&"sisyphus_contentedness"))
	_upgrade_boulder_size.pressed.connect(_increase_stat.bind(&"boulder_size"))
	_upgrade_hill_height.pressed.connect(_increase_stat.bind(&"hill_height"))
	_upgrade_hill_steepness.pressed.connect(_increase_stat.bind(&"hill_steepness"))
	focus_entered.connect(_upgrade_sisyphus_strength.grab_focus)
	for i in _upgrade_hat_list.get_child_count():
		var child := _upgrade_hat_list.get_child(i)
		if not child is OptionUnlocker:
			continue
		var hat := child as OptionUnlocker
		hat.unlocked.connect(unlock_hat.bind(i))
		hat.toggled.connect(toggle_hat.bind(i))
	for i in _upgrade_special_list.get_child_count():
		var child := _upgrade_special_list.get_child(i)
		if not child is OptionUnlocker:
			continue
		var special := child as OptionUnlocker
		special.unlocked.connect(unlock_special.bind(i))
		special.toggled.connect(toggle_special.bind(i))


func refresh() -> void:
	_sisyphus_strength.text = str(progress.sisyphus_strength)
	_sisyphus_speed.text = str(progress.sisyphus_speed)
	_sisyphus_contentedness.text = str(progress.sisyphus_contentedness)
	_boulder_size.text = str(progress.boulder_size)
	_hill_height.text = str(progress.hill_height)
	_hill_steepness.text = str(progress.hill_steepness)
	for i in _upgrade_hat_list.get_child_count():
		var child := _upgrade_hat_list.get_child(i)
		if not child is OptionUnlocker:
			continue
		var option := _upgrade_hat_list.get_child(i) as OptionUnlocker
		if progress.sisyphus_unlocked_hats & (2 ** i) > 0:
			option.is_unlocked = true
	for i in _upgrade_special_list.get_child_count():
		var child := _upgrade_special_list.get_child(i)
		if not child is OptionUnlocker:
			continue
		var option := _upgrade_special_list.get_child(i) as OptionUnlocker
		if progress.hill_unlocked_extras & (2 ** i) > 0:
			option.is_unlocked = true
	
	_upgrade_points.text = tr_n("%d point to spend", "%d points to spend", progress.upgrade_points) % progress.upgrade_points
	_upgrade_sisyphus_strength.disabled = (progress.sisyphus_strength >= 10 or progress.upgrade_points == 0)
	_upgrade_sisyphus_speed.disabled = (progress.sisyphus_speed >= 10 or progress.upgrade_points == 0)
	_upgrade_sisyphus_contentedness.disabled = (progress.upgrade_points == 0)
	_upgrade_boulder_size.disabled = (progress.boulder_size >= 10 or progress.upgrade_points == 0)
	_upgrade_hill_height.disabled = (progress.hill_height >= 10 or progress.upgrade_points == 0)
	_upgrade_hill_steepness.disabled = (progress.hill_steepness >= 10 or progress.upgrade_points == 0)
	for child in _upgrade_hat_list.get_children():
		if not child is OptionUnlocker:
			continue
		var hat := child as OptionUnlocker
		hat.disabled = (progress.upgrade_points == 0 and not hat.is_unlocked)
	for child in _upgrade_special_list.get_children():
		if not child is OptionUnlocker:
			continue
		var special := child as OptionUnlocker
		special.disabled = (progress.upgrade_points == 0 and not special.is_unlocked)


func _increase_stat(stat: StringName) -> void:
	progress.upgrade_points -= 1
	progress.set(stat, progress.get(stat) + 1)
	upgrade_chosen.emit(stat)
	refresh()


func unlock_hat(hat_index: int) -> void:
	progress.upgrade_points -= 1
	progress.sisyphus_unlocked_hats += 2 ** hat_index
	# TODO: Play an animation
	refresh()


func toggle_hat(toggled: bool, hat_index: int) -> void:
	if not toggled:
		hat_index = -hat_index
	progress.sisyphus_current_hats += hat_index
	upgrade_chosen.emit(&"swap_hat")


func unlock_special(index: int) -> void:
	progress.upgrade_points -= 1
	progress.hill_unlocked_extras += 2 ** index
	# TODO: Play an animation
	refresh()


func toggle_special(toggled: bool, index: int) -> void:
	var bit_flag := 2 ** index
	if not toggled:
		bit_flag = -bit_flag
	progress.hill_active_extras += bit_flag
