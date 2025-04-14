extends "res://character/modules/camera/CameraModule.gd"

@export var enabled: bool = true
@export var priority: int = 5

@export var distance: float = -4.0
@export var height: float = 1.7
@export var rotation_speed: float = 0.01
@export var clamp_vertical: Vector2 = Vector2(-70, 70)
@export var follow_lerp: float = 0.15
@export var use_character_yaw: bool = false  # ✅ switch here

var target_position := Vector3.ZERO

func handle_input(action: String, value: Variant) -> void:
	if action == "look" and value is Vector2:
		look_input = value

func apply(character: Node, _camera: Camera3D, _transform: Transform3D, _delta: float) -> Transform3D:
	if use_character_yaw:
		yaw = character.rotation.y
	else:
		yaw -= look_input.x * rotation_speed
		pitch -= look_input.y * rotation_speed
		pitch = clamp(pitch, clamp_vertical.x, clamp_vertical.y)

	var target : Vector3 = character.global_transform.origin + Vector3(0, height, 0)

	var direction := Vector3(
		sin(yaw) * cos(deg_to_rad(pitch)),
		sin(deg_to_rad(pitch)),
		cos(yaw) * cos(deg_to_rad(pitch))
	).normalized()

	var desired_position := target - direction * distance
	target_position = target_position.lerp(desired_position, follow_lerp)

	var transform := Transform3D().looking_at(target - target_position, Vector3.UP)
	transform.origin = target_position

	look_input = Vector2.ZERO
	return transform
