extends Node
class_name MovementController

@export var modules_dir: String = "res://Character/Modules/Movement"
@export var velocity: Vector3 = Vector3.ZERO
@export var MyInputController : InputController

@export var modules: Array[Node] = []

func _ready():
	ut.loadModulesFromDir(self, modules_dir, "res://character/modules/movement/MovementModule.gd", modules)
	if MyInputController and MyInputController.has_method("register_target"):
		MyInputController.register_target(self)

func _physics_process(delta: float):
	for m in modules:
		if m.properties['enabled']:
			velocity = m.apply(velocity, delta)

	# You might call `move_and_slide(velocity)` from parent script
func handle_input(action: String, value: Variant):
	for m in modules:
		if m.properties['enabled'] and m.has_method("handle_input"):
			m.handle_input(action, value)
