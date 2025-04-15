extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"name": "Turn",
	"enabled": true,
	"order": 2,
	"turn_speed": 0.01
}

var yaw : float = 0.0
var look_input := Vector2.ZERO

func handle_input(action: String, value: Variant) -> void:
	if action == "look" and value is Vector2:
		look_input = value

func apply(rotation: Vector3, _velocity: Vector3, _delta: float) -> Dictionary:
	if yaw == null:
		yaw = rotation.y

	# Apply rotation from look input
	if look_input.x != 0:
		yaw -= look_input.x * properties["turn_speed"]
		rotation.y = yaw
		look_input = Vector2.ZERO

	return {
		"rotation": rotation
	}
