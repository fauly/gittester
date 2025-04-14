extends "res://character/modules/camera/CameraModule.gd"

@export var enabled: bool = true
@export var priority: int = 5

@export var distance: float = 4.0
@export var height: float = 1.7
@export var rotation_speed: float = 0.01
@export var clamp_vertical: Vector2 = Vector2(-30, 60)
@export var follow_lerp: float = 0.15

var target_position := Vector3.ZERO

func handle_input(action: String, value: Variant) -> void:
	if action == "look" and value is Vector2:
		print("Received look:", value)
		look_input = value


func apply(character: Node, _camera: Camera3D, _transform: Transform3D, _delta: float) -> Transform3D:
	yaw -= look_input.x * rotation_speed
	pitch -= look_input.y * rotation_speed
	pitch = clamp(pitch, clamp_vertical.x, clamp_vertical.y)

	# Get the follow origin (character body position + offset)
	var target_position = character.global_transform.origin + Vector3(0, height, 0)

	# Create rotation basis from yaw and pitch
	var direction := Vector3(
		sin(yaw) * cos(deg_to_rad(pitch)),
		sin(deg_to_rad(pitch)),
		cos(yaw) * cos(deg_to_rad(pitch))
	).normalized()

	var camera_position : Vector3 = target_position - direction * distance

	# Interpolate smoothly toward new position
	self.target_position = self.target_position.lerp(camera_position, follow_lerp)

	# Make the camera look at the target
	var transform := Transform3D().looking_at(target_position - self.target_position, Vector3.UP)
	transform.origin = self.target_position

	return transform
