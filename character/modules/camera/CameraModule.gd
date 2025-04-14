extends Node
class_name CameraModule

@export var moduleName: String

var yaw := 0.0
var pitch := 0.0
var look_input := Vector2.ZERO

func apply(_character: Node, _camera: Camera3D, transform: Transform3D, _delta: float) -> Transform3D:
	return transform

func handle_input(action: String, value: Variant) -> void:
	if action == "look" and value is Vector2:
		look_input = value
