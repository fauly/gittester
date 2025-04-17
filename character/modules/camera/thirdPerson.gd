@tool
extends "res://character/modules/CameraModule.gd"

@export var properties := {
	"name": "Third Person",
	"enabled": true,
	"order": 5,
	"distance": 4.0,
	"height": 1.7,
	"rotation_speed": 0.01,
	"clamp_vertical": Vector2(-20, 20),
	"use_character_yaw": true,
	"min_distance": 1.0,
	"collision_bounce": 10.0
}

var pivot: Transform3D = Transform3D.IDENTITY
var current_position: Vector3 = Vector3.ZERO

func requires_pivot() -> bool:
	return true

func handle_input(action: String, value: Variant) -> void:
	if action == "look" and value is Vector2:
		look_input = value

func apply(character: Node, _camera: Camera3D, _transform: Transform3D, _delta: float) -> Transform3D:
	var dist: float = properties["distance"]
	var height: float = properties["height"]
	var speed: float = properties["rotation_speed"]
	var verticalclamp: Vector2 = properties["clamp_vertical"]
	var use_yaw: bool = properties["use_character_yaw"]
	var min_dist: float = properties["min_distance"]
	var bounce_deg: float = properties["collision_bounce"]

	if use_yaw:
		yaw = character.rotation.y
		pitch = clampf(pitch - look_input.y * speed, deg_to_rad(verticalclamp.x), deg_to_rad(verticalclamp.y))
	else:
		yaw -= look_input.x * speed
		pitch = clampf(pitch - look_input.y * speed, deg_to_rad(verticalclamp.x), deg_to_rad(verticalclamp.y))

	# Step 1: Base pivot origin
	var pivot_pos = character.global_transform.origin + Vector3(0, height, 0)

	# Step 2: Apply yaw to identity
	var yaw_basis := Basis().rotated(Vector3.UP, yaw)

	# Step 3: Get local X axis from yawed basis
	var pitch_axis = yaw_basis.x

	# Step 4: Apply pitch on local X
	var full_basis = yaw_basis.rotated(pitch_axis, pitch)

	# Step 5: Update pivot transform
	pivot.origin = pivot_pos
	pivot.basis = full_basis

	# Step 6: Desired camera position
	var desired_pos = pivot * Vector3(0, 0, -dist)

	# Step 7: Spring arm raycast
	var space_state = character.get_world_3d().direct_space_state
	var ray = PhysicsRayQueryParameters3D.create(pivot_pos, desired_pos)
	ray.exclude = [character.get_rid()]
	var result = space_state.intersect_ray(ray)

	if result:
		var hit_distance : float = pivot_pos.distance_to(result.position)
		var safe_dist : float = max(hit_distance - 0.2, min_dist)

		if safe_dist <= min_dist:
			yaw += deg_to_rad(bounce_deg)
			var bounce_basis := Basis().rotated(Vector3.UP, yaw)
			var bounce_axis := bounce_basis.x
			full_basis = bounce_basis.rotated(bounce_axis, pitch)
			pivot.basis = full_basis
			desired_pos = pivot * Vector3(0, 0, safe_dist)
		else:
			desired_pos = pivot * Vector3(0, 0, safe_dist)

	# Step 8: Construct transform looking at the character
	var look_dir = (pivot_pos - desired_pos).normalized()
	var basis = Basis.looking_at(look_dir, Vector3.UP)

	look_input = Vector2.ZERO
	return Transform3D(basis, desired_pos)
