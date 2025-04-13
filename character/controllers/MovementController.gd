@tool
extends Node
class_name MovementController

@export var modules_dir: String = "res://Character/Modules/Movement"
@export var velocity: Vector3 = Vector3.ZERO
@export var InputController : Node

var modules: Array[MovementModule] = []

func _ready():
	_load_modules_from_dir()
	if InputController and InputController.has_method("register_target"):
		InputController.register_target(self)

func _physics_process(delta: float):
	for m in modules:
		if m.enabled:
			velocity = m.apply(velocity, delta)

	# You might call `move_and_slide(velocity)` from parent script
func handle_input(action: String, value: Variant):
	for m in modules:
		if m.enabled and m.has_method("handle_input"):
			m.handle_input(action, value)

func _load_modules_from_dir():
	for child in get_children():
		if child is MovementModule:
			remove_child(child)
			child.queue_free()

	modules.clear()

	# Load new
	var paths: Array = []
	ut.appendDir(modules_dir, paths, "*.gd")

	for path in paths:
		var script = load(path)
		if script and script is GDScript:
			var node: Node = script.new()
			if node is MovementModule:
				add_child(node)
				modules.append(node)
