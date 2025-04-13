extends Node
class_name CameraModule

@export var moduleName: String
@export var enabled: bool = true
@export var priority: int = 0

var yaw := 0.0
var pitch := 0.0
var look_input := Vector2.ZERO

func apply(character: Node, camera: Camera3D, transform: Transform3D, delta: float) -> Transform3D:
	return transform

func handle_input(action: String, value: Variant) -> void:
	if action == "look" and value is Vector2:
		look_input = value
