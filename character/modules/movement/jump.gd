extends "res://character/modules/movement/MovementModule.gd"

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

func apply(_rotation: Vector3, _velocity: Vector3, _delta: float) -> Dictionary:
	var delta_v := Vector3.ZERO

	if body and jump_requested:
		if body.is_on_floor():
			delta_v.y = properties["jump_force"]
		jump_requested = false

	return {
		"velocity": delta_v
	}
