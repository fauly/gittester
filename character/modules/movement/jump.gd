extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"name": "Jump",
	"enabled": true,
	"jump_force": 8.0
}

var jump_requested := false

func handle_input(action: String, value: Variant):
	if action == "jump":
		print('value',value)
		jump_requested = true

func apply(_rotation: Vector3, velocity: Vector3, _delta: float) -> Dictionary:
	if body and body.is_on_floor() and jump_requested:
		velocity.y = properties["jump_force"]
		jump_requested = false
	elif jump_requested:
		jump_requested = false

	return {
		"velocity": velocity
	}
