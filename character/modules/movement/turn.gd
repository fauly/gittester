extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"name": "Turn",
	"enabled": true,
	"turn_speed": 0.01
}

var yaw : Variant = null
var look_input := Vector2.ZERO

func handle_input(action: String, value: Variant):
	if action == "look" and value is Vector2:
		look_input = value

func apply(rotation: Vector3, _velocity: Vector3, _delta: float) -> Dictionary:
	if yaw == null:
		yaw = rotation.y  # Initialize to current Y-rotation on first run

	yaw -= look_input.x * properties["turn_speed"]
	rotation.y = yaw
	look_input = Vector2.ZERO

	return {
		"rotation": rotation
	}
