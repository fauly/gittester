extends CameraModule

@export var head_ground_offset: Vector3 = Vector3(0, 1.7, 0)
@export var rotation_speed: float = 0.1
@export var clamp_vertical: Vector2 = Vector2(-90, 90)

func apply(character: Node, camera: Camera3D, transform: Transform3D, delta: float) -> Transform3D:
	yaw -= look_input.x * rotation_speed * delta
	pitch -= look_input.y * rotation_speed * delta
	pitch = clamp(pitch, clamp_vertical.x, clamp_vertical.y)

	var basis = Basis()
	basis = basis.rotated(Vector3.UP, yaw)
	basis = basis.rotated(Vector3.RIGHT, pitch)

	var origin: Vector3 = character.global_transform.origin + head_ground_offset
	return Transform3D(basis, origin)
