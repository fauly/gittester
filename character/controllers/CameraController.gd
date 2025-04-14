extends Node3D
class_name CameraController

@export var use_global_transform: bool = true
@export var MyInputController : Node
@export var camera : Camera3D
@export var transitioner: Node
@export var shaderer: Node
@export var modules_dir: String = "res://character/modules/camera"
@export var character: CharacterBody3D

var modules: Array[CameraModule] = []
var last_transform: Transform3D

func reload_modules():
	_load_modules_from_dir()

func _ready():
	last_transform = global_transform
	_load_modules_from_dir()
	if MyInputController.has_method("register_target"):
		MyInputController.register_target(self)

func _process(delta: float):
	var thistransform = _get_target_transform(character, delta)
	var blended = _blend_transform(thistransform, delta)
	_apply_transform(blended)
	_update_shader(delta, character)
	last_transform = blended

func _get_target_transform(targetcharacter: Node, delta: float) -> Transform3D:
	var thistransform := last_transform

	var active_module : Node = null
	var top_priority := -999
	
	for m in modules:
		if m.enabled and m.priority > top_priority:
			active_module = m
			top_priority = m.priority

	if active_module:
		thistransform = active_module.apply(targetcharacter, camera, transform, delta)

	return thistransform

func _blend_transform(target: Transform3D, delta: float) -> Transform3D:
	if transitioner and transitioner.has_method("apply"):
		return transitioner.apply(last_transform, target, self, delta)
	return target

func _apply_transform(thistransform: Transform3D):
	if use_global_transform:
		global_transform = thistransform
	else:
		self.transform = thistransform

func _update_shader(delta: float, targetcharacter: Node):
	if shaderer and shaderer.has_method("update_shader"):
		shaderer.update_shader(delta, targetcharacter, self)

func handle_input(action: String, value: Variant):
	print("Received input ",action,value)
	for m in modules:
		if m.enabled:
			m.handle_input(action, value)

func _load_modules_from_dir():
	ut.loadModulesFromDir(self, modules_dir, "res://character/modules/camera/CameraModule.gd", modules)
