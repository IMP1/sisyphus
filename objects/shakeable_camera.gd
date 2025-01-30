extends Camera2D
class_name ShakeableCamera2D

signal all_shakes_finished

@export var noise: Noise
@export var shake_strength_modifier: float = 1.0

var rumble_strength: Vector2 = Vector2.ZERO
var shakes: Array[Shake] = []

var noise_row: int = 0


func stop() -> void:
	_clear_screen_shake()


func _clear_screen_shake() -> void:
	rumble_strength = Vector2.ZERO
	shakes.clear()


func add_screen_rumble(velocity: Vector2) -> void:
	rumble_strength += velocity


func add_screen_shake_constant(duration: float, strength: Vector2) -> void:
	var shake := Shake.new()
	shake.duration = duration
	shake.strength = strength
	shakes.append(shake)


func add_screen_shake_curve(duration: float, strength_x: Curve, strength_y: Curve=null) -> void:
	var shake := Shake.new()
	shake.duration = duration
	shake.strength_curve_x = strength_x
	shake.strength_curve_y = strength_y
	shakes.append(shake)


func _process(delta: float) -> void:
	if shake_strength_modifier <= 0.0:
		return
	if rumble_strength == Vector2.ZERO and shakes.is_empty():
		return
	var total_shake := rumble_strength * shake_strength_modifier
	var finished_shakes: Array[int] = []
	for i in shakes.size():
		var shake := shakes[i]
		shake.time += delta
		if shake.time >= shake.duration:
			finished_shakes.append(i)
			continue
		if shake.strength_curve_x and shake.strength_curve_y:
			total_shake.x += shake.strength_curve_x.sample(shake.time / shake.duration) * shake_strength_modifier
			total_shake.y += shake.strength_curve_y.sample(shake.time / shake.duration) * shake_strength_modifier
		elif shake.strength_curve_x:
			total_shake.x += shake.strength_curve_x.sample(shake.time / shake.duration) * shake_strength_modifier
			total_shake.y += shake.strength_curve_x.sample(shake.time / shake.duration) * shake_strength_modifier
		else:
			total_shake += shake.strength * shake_strength_modifier
	offset.x = total_shake.x * randf_range(-1, 1) # remap(noise.get_noise_2d(64, noise_row), 0, 1, -1, 1)
	offset.y = total_shake.y * randf_range(-1, 1) # remap(noise.get_noise_2d(128, noise_row), 0, 1, -1, 1)
	noise_row += 1
	if shakes.is_empty():
		return
	finished_shakes.reverse()
	for i in finished_shakes:
		shakes.remove_at(i)
	if shakes.is_empty():
		all_shakes_finished.emit()


class Shake:
	var duration: float
	var strength: Vector2
	var time: float = 0
	var strength_curve_x: Curve = null
	var strength_curve_y: Curve = null
