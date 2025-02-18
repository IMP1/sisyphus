extends CanvasLayer

signal transition_completed

const DEFAULT_ANIM = &"fade_black"

@export var fade: ColorRect
@export var previous_scene_container: SubViewport
@export var next_scene_container: SubViewport
@export var previous_scene_texture: SubViewportContainer
@export var next_scene_texture: SubViewportContainer

var animations: Dictionary # Dictionary[StringName, Callable]
var _scene_stack: Array[Node]


func _ready() -> void:
	visible = false
	
	var fade_black_anim := func(prev_scene: Node, next_scene: Node, duration: float):
		fade.color = Color(Color.BLACK, 0)
		previous_scene_texture.visible = true
		next_scene_texture.visible = false
		var tween := create_tween()
		tween.tween_property(fade, ^"color", Color.BLACK, duration / 2.0)
		tween.tween_property(previous_scene_texture, ^"visible", false, 0)
		tween.tween_property(prev_scene, ^"visible", false, 0)
		tween.tween_property(next_scene, ^"visible", true, 0)
		tween.tween_property(next_scene_texture, ^"visible", true, 0)
		tween.tween_property(fade, ^"color", Color(Color.BLACK, 0), duration / 2.0)
		await tween.finished
	animations[&"fade_black"] = fade_black_anim


func _transition(prev_scene: Node, next_scene: Node, transition: StringName, duration:float, free_prev_scene:bool, add_next_scene:bool) -> void:
	visible = true
	
	if add_next_scene:
		get_tree().root.add_child(next_scene)
		await get_tree().process_frame
	
	var prev_prev_scene_parent := prev_scene.get_parent()
	var prev_next_scene_parent := next_scene.get_parent()
	prev_scene.reparent(previous_scene_container)
	next_scene.reparent(next_scene_container)
	var animation := animations[transition] as Callable
	await animation.call(prev_scene, next_scene, duration)
	prev_scene.reparent(prev_prev_scene_parent)
	next_scene.reparent(prev_next_scene_parent)
	
	if free_prev_scene:
		prev_scene.queue_free()
	
	get_tree().current_scene = next_scene
	
	visible = false
	transition_completed.emit()


func is_transitioning() -> bool:
	return visible


func change_scene_to_packed(next_scene: PackedScene, transition:=DEFAULT_ANIM, duration:float=1.0) -> void:
	var scene_node := next_scene.instantiate()
	await change_scene_to_node(scene_node, transition, duration)


func change_scene_to_node(next_scene: Node, transition:=DEFAULT_ANIM, duration:float=1.0) -> void:
	await _transition(get_tree().current_scene, next_scene, transition, duration, true, true)


func push_scene(next_scene: Node, transition:=DEFAULT_ANIM, duration:float=1.0) -> void:
	_scene_stack.push_back(get_tree().current_scene)
	await _transition(get_tree().current_scene, next_scene, transition, duration, false, true)


func pop_scene(transition:=DEFAULT_ANIM, duration:float=1.0) -> void:
	assert(_scene_stack.size() >= 1)
	var next_scene := _scene_stack.pop_back() as Node # Actually an old scene but also the new scene
	await _transition(get_tree().current_scene, next_scene, transition, duration, true, false)
