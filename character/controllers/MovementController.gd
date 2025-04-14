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
	if MyInputController and MyInputController.has_method("register_target"):
		MyInputController.register_target(self)

func handle_input(action: String, value: Variant):
	for m in modules:
		if m.properties.has("enabled") and m.properties["enabled"]:
			if m.has_method("handle_input"):
				m.handle_input(action, value)


func _physics_process(delta: float):
	rotation = owner.rotation
	var previous_velocity = velocity
	var previous_rotation = rotation

	for m in modules:
		if not m.properties["enabled"]:
			continue

		var result: Dictionary = m.apply(rotation, velocity, delta)

		var updated_velocity = velocity
		var updated_rotation = rotation

		if result.has("velocity"):
			updated_velocity = result["velocity"]
		if result.has("rotation"):
			updated_rotation = result["rotation"]

		var changes := []

		if updated_velocity != previous_velocity:
			changes.append(["velocity changed: ",updated_velocity])
		if updated_rotation != previous_rotation:
			changes.append(["rotation changed: ",updated_rotation])

		#if changes.size() > 0:
			#print("🧩 [{0}] → {1}".format([m.properties.get("name"), str(m.name)]), ", ".join(changes))

		velocity = updated_velocity
		rotation = updated_rotation
		previous_velocity = velocity
		previous_rotation = rotation
