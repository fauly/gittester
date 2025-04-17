extends Node
class_name MovementController

@export var MyInputController : InputController
@export var myTarget: PhysicsBody3D

var velocity: Vector3 = Vector3.ZERO
var rotation: Vector3 = Vector3.ZERO
var modules: Array = []

func _ready():
	modules = ModuleManager.getModules(ModuleManager.TYPE_MOVEMENT)
	
	for m in modules:
		m.body = myTarget
	
	if MyInputController and MyInputController.has_method("register_target"):
		MyInputController.register_target(self)

func handle_input(action: String, value: Variant):
	for m in modules:
		if m.has_method("handle_input"):
			m.handle_input(action, value)
signal debug_update(debug_data: Array)

func _physics_process(delta: float):
	var debug_log := []

	var motion_state := {
		"velocity": velocity,
		"rotation": rotation
	}

	for i in range(modules.size()):
		var m = modules[i]
		if m.has_method("apply"):
			var before := motion_state.duplicate(true)
			motion_state = m.apply(motion_state, delta)
			var after := motion_state.duplicate(true)

			debug_log.append({
				"name": m.properties.get("name", "Unnamed"),
				"before": before,
				"after": after
			})

	# Move character
	if myTarget:
		myTarget.velocity = motion_state.get("velocity", Vector3.ZERO)
		myTarget.rotation = motion_state.get("rotation", Vector3.ZERO)
		myTarget.move_and_slide()

	velocity = motion_state.get("velocity", velocity)
	rotation = motion_state.get("rotation", rotation)

	# Emit debug data
	emit_signal("debug_update", debug_log)
