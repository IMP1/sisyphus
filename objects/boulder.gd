extends CharacterBody2D
class_name Boulder

signal started_moving
signal stopped_moving
signal reset

const PLAYER_PHYSICS_LAYER := 2
const BOULDER_PHYSICS_LAYER := 3

@export var size: int = 0
@export var weight: int = 0

var is_ignoring_player: bool
var push_direction: Vector2
var gravity_speed: float = 0

@onready var _slope_raycast := $SlopeRay as RayCast2D
@onready var _reset_area := $ResetArea as Area2D
@onready var _scrape_sound := $ScrapeSound as AudioStreamPlayer2D
@onready var _particles := $ResetArea/GPUParticles2D as GPUParticles2D


func _ready() -> void:
	_reset_area.body_entered.connect(_player_reset)
	_player_reset(null)


func _set_size(new_size: int) -> void:
	size = new_size
	# TODO: Set size of collision shape and polygon
	# TODO: Play an animation?


func push(direction: Vector2) -> void:
	if is_ignoring_player:
		return
	push_direction = direction
	# TODO: Go slower nearer the top?


func _physics_process(delta: float) -> void:
	$Debug/States/OnSlope.visible = _slope_raycast.is_colliding()
	$Debug/States/BeingPushed.visible = (push_direction != Vector2.ZERO and not is_ignoring_player)
	velocity = push_direction
	if not is_on_floor():
		gravity_speed += 100 * delta
	elif _slope_raycast.is_colliding() and push_direction != Vector2.ZERO:
		pass
		#gravity_speed += 100 * delta
	else:
		gravity_speed = 0
	velocity.y += gravity_speed
	move_and_slide()
	if velocity == Vector2.ZERO and _scrape_sound.playing:
		_scrape_sound.stop()
		stopped_moving.emit()
	elif velocity != Vector2.ZERO and not _scrape_sound.playing:
		_scrape_sound.play()
		started_moving.emit()


func _wait_for_reset() -> void:
	_reset_area.monitoring = true
	_reset_area.visible = true
	_particles.emitting = true


func ignore_player_contact() -> void:
	set_collision_layer_value(BOULDER_PHYSICS_LAYER, false)
	set_collision_mask_value(PLAYER_PHYSICS_LAYER, false)
	$Debug/States/IgnoringPlayer.visible = true
	$Polygon2D.color = Color("d9a066")


func _player_reset(_player) -> void:
	$Debug/States/IgnoringPlayer.visible = false
	is_ignoring_player = false
	set_collision_layer_value(BOULDER_PHYSICS_LAYER, true)
	set_collision_mask_value(PLAYER_PHYSICS_LAYER, true)
	_reset_area.set_deferred(&"monitoring", false)
	_reset_area.visible = false
	$Polygon2D.color = Color("eec39a")
	_particles.emitting = false
	reset.emit()
