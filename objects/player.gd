extends CharacterBody2D
class_name Player

signal stopped_pushing
signal moved(distance: Vector2)

const SPEEDS: Array[float] = [
	64.0,
	80.0,
	96.0,
]

@export var speed: int = 0
@export var strenth: int = 0
@export var contentedness: int = 0

var pushing: bool

@onready var slope_raycast := $SlopeRay as RayCast2D
@onready var boulder_raycast_flat := $BoulderRayFlat as RayCast2D
@onready var boulder_raycast_slope := $BoulderRaySlope as RayCast2D
@onready var sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var footstep_sound := $FootstepsSound as AudioStreamPlayer2D


func _ready() -> void:
	sprite.frame_changed.connect(func():
		if sprite.frame == 0 and not sprite.animation.begins_with("Idle"):
			footstep_sound.pitch_scale = randf_range(0.8, 1.2)
			footstep_sound.play())


func _physics_process(delta: float) -> void:
	velocity.x = 0
	if not is_on_floor():
		velocity.y += 10
	var movement := Input.get_axis(&"move_left", &"move_right")
	if not is_on_floor():
		movement /= 3.0
	if not is_equal_approx(movement, 0.0):
		velocity.x = movement * SPEEDS[speed]
	_update_sprite(velocity)
		# TODO: Check if pushing and slow down relative to weight and strength and slope and terrain
	var pos := position
	move_and_slide()
	var distance := position - pos
	if is_on_floor():
		moved.emit(distance)
	if is_pushing():
		_push_boulder(delta)
	elif pushing:
		stopped_pushing.emit()
		pushing = false
	$Debug/States/OnSlope.visible = slope_raycast.is_colliding()
	$Debug/States/PushingBoulder.visible = boulder_raycast_flat.is_colliding()
	$Debug/States/Falling.visible = not is_on_floor()


func _update_sprite(movement: Vector2) -> void:
	if not is_on_floor(): #movement.y > 0.3 and absf(movement.x) < 0.2:
		sprite.play(&"Falling")
	elif not is_equal_approx(movement.x, 0.0):
		if slope_raycast.is_colliding():
			if movement.x > 0:
				if is_pushing():
					sprite.play(&"PushUp")
				else:
					sprite.play(&"WalkUp")
			elif movement.x < 0:
				sprite.play(&"WalkDown")
		else:
			if is_pushing():
				sprite.play(&"PushFlat")
			else:
				sprite.play(&"WalkFlat")
			sprite.flip_h = (movement.x < 0)
	else:
		if slope_raycast.is_colliding():
			sprite.play(&"IdleSlope")
		else:
			sprite.play(&"Idle")


func is_pushing() -> bool:
	if not boulder_raycast_flat.is_colliding() and not boulder_raycast_slope.is_colliding():
		return false
	var boulder: Boulder
	if boulder_raycast_flat.is_colliding():
		boulder = boulder_raycast_flat.get_collider() as Boulder
	else:
		boulder = boulder_raycast_slope.get_collider() as Boulder
	if sign(velocity.x) != sign(boulder.position.x - position.x):
		return false # Can't push it the other way
	return true


func _push_boulder(_delta: float) -> void:
	var boulder: Boulder
	if boulder_raycast_flat.is_colliding():
		boulder = boulder_raycast_flat.get_collider() as Boulder
	else:
		boulder = boulder_raycast_slope.get_collider() as Boulder
	var push := velocity
	if boulder_raycast_flat.is_colliding() and boulder_raycast_slope.is_colliding():
		push += Vector2.UP + Vector2.RIGHT
		push *= 2
	boulder.push(push)
	pushing = true
