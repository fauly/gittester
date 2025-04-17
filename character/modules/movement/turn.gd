@tool
extends "res://character/modules/MovementModule.gd"

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

func apply(motion_state: Dictionary, _delta: float) -> Dictionary:
	var rotation = motion_state.get("rotation", Vector3.ZERO)

	if yaw == null:
		yaw = rotation.y

	if look_input.x != 0:
		yaw -= look_input.x * properties["turn_speed"]
		rotation.y = yaw
		look_input = Vector2.ZERO

	motion_state["rotation"] = rotation
	return motion_state
