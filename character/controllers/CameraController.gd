@tool
extends Node3D
class_name CameraController

@export var use_global_transform: bool = true
@export var InputController : Node
@export var camera : Camera3D
@export var transitioner: Node
@export var shaderer: Node
@export var modules_dir: String = "res://character/modules/camera"

var modules: Array[CameraModule] = []
var last_transform: Transform3D

@export_tool_button("Reload Modules","Reload") var reload_modules_btn = reload_modules

func reload_modules():
	_load_modules_from_dir()

func _ready():
	last_transform = global_transform
	if not Engine.is_editor_hint():
		_load_modules_from_dir()
		if InputController.has_method("register_target"):
			InputController.register_target(self)

func _process(delta: float):
	var character = get_parent()
	var transform = _get_target_transform(character, delta)
	var blended = _blend_transform(transform, delta)
	_apply_transform(blended)
	_update_shader(delta, character)
	last_transform = blended

func _get_target_transform(character: Node, delta: float) -> Transform3D:
	var transform = last_transform

	var sorted = modules.filter(func(m): return m.enabled)
	sorted.sort_custom(func(a, b): return a.priority > b.priority)

	for m in sorted:
		transform = m.apply(character, camera, transform, delta)

	return transform

func _blend_transform(target: Transform3D, delta: float) -> Transform3D:
	if transitioner and transitioner.has_method("apply"):
		return transitioner.apply(last_transform, target, self, delta)
	return target

func _apply_transform(transform: Transform3D):
	if use_global_transform:
		global_transform = transform
	else:
		self.transform = transform

func _update_shader(delta: float, character: Node):
	if shaderer and shaderer.has_method("update_shader"):
		shaderer.update_shader(delta, character, self)

func handle_input(action: String, value: Variant):
	for m in modules:
		if m.enabled:
			m.handle_input(action, value)

func _load_modules_from_dir():
	for child in get_children():
		if child is CameraModule:
			remove_child(child)
			child.queue_free()

	modules.clear()

	var paths: Array = []
	ut.appendDir(modules_dir, paths, "*.gd")

	for path in paths:
		var script = load(path)
		if script and script is GDScript:
			var node: Node = script.new()
			if node is CameraModule:
				add_child(node)
				modules.append(node)
