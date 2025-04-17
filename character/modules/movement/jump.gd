@tool
extends "res://character/modules/MovementModule.gd"

@export var properties := {
	"name": "Jump",
	"enabled": true,
	"order": 50,
	"jump_force": 8.0
}

var jump_requested := false

func handle_input(action: String, value: Variant) -> void:
	if action == "jump" and typeof(value) == TYPE_BOOL and value:
		jump_requested = true

func apply(motion_state: Dictionary, _delta: float) -> Dictionary:
	if body and jump_requested:
		if body.is_on_floor():
			var velocity = motion_state.get("velocity", Vector3.ZERO)
			velocity.y = properties["jump_force"]
			motion_state["velocity"] = velocity
		jump_requested = false
	return motion_state
