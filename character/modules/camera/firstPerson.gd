@tool
extends "res://character/modules/CameraModule.gd"

@export var properties := {
	"name": "First Person",
	"enabled": true,
	"order": 1,
	"head_ground_offset": Vector3(0, 1.7, 0),
	"rotation_speed": 0.1,
	"clamp_vertical": Vector2(-90, 90)
}

func apply(character: Node, _camera: Camera3D, _transform: Transform3D, delta: float) -> Transform3D:
	var rot_speed = properties["rotation_speed"]
	var clamp_vertical = properties["clamp_vertical"]
	var head_offset = properties["head_ground_offset"]

	yaw -= rot_speed * look_input.x * delta
	pitch -= rot_speed * look_input.y * delta
	pitch = clamp(pitch, clamp_vertical.x, clamp_vertical.y)

	var basis = Basis()
	basis = basis.rotated(Vector3.UP, yaw)
	basis = basis.rotated(Vector3.RIGHT, pitch)

	var origin: Vector3 = character.global_transform.origin + head_offset
	return Transform3D(basis, origin)
