extends Node
class_name MovementController

@export var modules_dir: String = "res://Character/Modules/Movement"
@export var MyInputController : InputController
@export var myTarget: PhysicsBody3D

@export var modules: Array[Node] = []

var velocity: Vector3 = Vector3.ZERO
var rotation: Vector3 = Vector3.ZERO

func _ready():
	ut.loadModulesFromDir(self, modules_dir, "res://character/modules/movement/MovementModule.gd", modules)
	for m in modules:
		if m.properties["enabled"]:
			m.order = m.properties.get("order", 0)
	modules.sort_custom(func(a, b): return a.order > b.order)
	if MyInputController and MyInputController.has_method("register_target"):
		MyInputController.register_target(self)

func handle_input(action: String, value: Variant):
	for m in modules:
		if m.properties.has("enabled") and m.properties["enabled"]:
			if m.has_method("handle_input"):
				m.handle_input(action, value)


func _physics_process(delta: float):
	rotation = owner.rotation
	var accumulated_velocity := Vector3.ZERO
	var current_rotation := rotation

	var module_index := 0

	for m in modules:
		if not m.properties["enabled"]:
			continue

		var result: Dictionary = m.apply(current_rotation, velocity, delta)

		var changes := []
		var mod_name = m.properties.get("name", m.name)

		if result.has("velocity"):
			var contribution : Vector3 = result["velocity"]
			accumulated_velocity += contribution
			changes.append("velocity += " + str(contribution))

		if result.has("rotation"):
			var new_rot : Vector3 = result["rotation"]
			if new_rot != current_rotation:
				current_rotation = new_rot
				changes.append("rotation → " + str(new_rot))

		if changes.size() > 0:
			print("🧩 #{2} [{0}] → {1}".format([m.properties.get("name"), str(m.name),module_index]), ", ".join(changes))
		
		module_index += 1
	velocity = accumulated_velocity
	rotation = current_rotation
	#print("✅ Final Velocity: ", velocity)
