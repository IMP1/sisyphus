@tool
extends StaticBody2D
class_name Hill

signal boulder_reached_top

@export var distance: float = 200:
	set(value):
		distance = value
		_refresh()
@export_range(0.0, 1.0) var steepness: float = 0.5:
	set(value):
		steepness = value
		_refresh()
@export var random_seed: int:
	set(value):
		random_seed = value
		_refresh()

@onready var _top_area := $Top as Area2D


func _ready() -> void:
	_top_area.body_entered.connect(boulder_reached_top.emit)


func _refresh() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	var angle := steepness * PI / 2
	var base_length := distance / sin(angle)
	var height := distance / cos(angle)
	var polygon := PackedVector2Array()
	polygon.append(Vector2.ZERO)
	var n := floori(distance / 50) + rng.randi_range(-2, 6)
	for i in n:
		var vec := Vector2(base_length, -height) * (i+1) / (n+1)
		vec += Vector2.from_angle(rng.randf() * TAU) * rng.randf_range(2, 6)
		polygon.append(vec)
	polygon.append(Vector2(base_length, -height))
	polygon.append(Vector2(base_length * 2, 0))
	polygon.append(Vector2(base_length * 2, 256))
	polygon.append(Vector2(0, 256))
	$CollisionPolygon2D.polygon = polygon
	$Polygon2D.polygon = polygon
	$Top.rotation = -angle
	$Top.position = Vector2(base_length, -height) * 0.9
	$Surface.points = polygon
