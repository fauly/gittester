@tool
extends Node3D
class_name CameraController

@export var use_global_transform: bool = true
@export var MyInputController: Node
@export var camera: Camera3D
@export var transitioner: Node
@export var shaderer: Node
@export var character: CharacterBody3D

var modules: Array = []
var last_transform: Transform3D
var pivot_transform := Transform3D.IDENTITY
var pivoter: Node3D = null

signal debug_update(debug_data: Array)


func _ready() -> void:
	last_transform = global_transform
	modules = ModuleManager.getModules(ModuleManager.TYPE_CAMERA)

	if MyInputController and MyInputController.has_method("register_target"):
		MyInputController.register_target(self)

	# Setup pivot node
	_init_pivot()

func _process(delta: float) -> void:
	if pivoter and character:
		var height := 1.7  # Default height offset
		var pivot_origin := character.global_transform.origin + Vector3.UP * height
		pivoter.global_position = pivot_origin
		pivot_transform.origin = pivot_origin
		pivot_transform.basis = pivoter.global_transform.basis

	var transform_result = _apply_modules(delta)
	var blended = _blend_transform(transform_result, delta)
	_apply_transform(blended)
	_update_shader(delta, character)
	last_transform = blended

func _apply_modules(delta: float) -> Transform3D:
	var base_transform = last_transform
	var debug_log := []

	for module in modules:
		if not module.properties.get("enabled", false):
			continue

		var is_additive : bool = module.has_method("is_additive") and module.is_additive()
		var needs_pivot : bool = module.has_method("requires_pivot") and module.requires_pivot()

		if needs_pivot:
			module.pivot = pivot_transform
			module.camera_node = camera

		var before : Transform3D = base_transform
		var result : Transform3D = module.apply(character, camera, base_transform, delta)
		var after : Transform3D = result

		debug_log.append({
			"source": "Camera",
			"name": module.properties.get("name", "Unnamed"),
			"before": before,
			"after": after
		})

		if is_additive:
			base_transform.origin += result.origin - base_transform.origin
			base_transform.basis = base_transform.basis.slerp(result.basis, 0.5)
		else:
			base_transform = result

	# Emit runtime debug info
	emit_signal("debug_update", debug_log)

	return base_transform


func _blend_transform(target: Transform3D, delta: float) -> Transform3D:
	if transitioner and transitioner.has_method("apply"):
		return transitioner.apply(last_transform, target, self, delta)
	return target

func _apply_transform(new_transform: Transform3D) -> void:
	if use_global_transform:
		global_transform = new_transform
	else:
		transform = new_transform

func _update_shader(delta: float, targetcharacter: Node) -> void:
	if shaderer and shaderer.has_method("update_shader"):
		shaderer.update_shader(delta, targetcharacter, self)

func handle_input(action: String, value: Variant) -> void:
	for m in modules:
		if m.properties.get("enabled", false) and m.has_method("handle_input"):
			m.handle_input(action, value)

func _init_pivot() -> void:
	if not pivoter:
		pivoter = Node3D.new()
		pivoter.name = "CameraPivot"
		add_child(pivoter)
