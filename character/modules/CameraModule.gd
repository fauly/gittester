@tool
extends Node

var look_input := Vector2.ZERO
var camera_node : Camera3D = null
var yaw : float = 0.0
var pitch : float = 0.0

func is_additive() -> bool:
	return false  # Can be overridden

func requires_pivot() -> bool:
	return false  # Can be overridden

func handle_input(action: String, value: Variant) -> void:
	if action == "look" and value is Vector2:
		look_input = value

func apply(_character: Node, _camera: Camera3D, transform: Transform3D, _delta: float) -> Transform3D:
	return transform
