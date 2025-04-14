extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"name": "Walk",
	"enabled": true,
	"walk_speed": 5.0
}

var input_axis := Vector3.ZERO
var pressed := {}

const MOVE_MAP := {
	"move_forward": Vector3(0, 0, -1),
	"move_back":    Vector3(0, 0,  1),
	"move_left":    Vector3(-1, 0, 0),
	"move_right":   Vector3( 1, 0, 0),
}

func handle_input(action: String, value: Variant):
	if action in MOVE_MAP:
		pressed[action] = value
		_update_input_axis()

func _update_input_axis():
	input_axis = Vector3.ZERO
	for action in MOVE_MAP:
		if pressed.get(action, false):
			input_axis += MOVE_MAP[action]
	input_axis = input_axis.normalized()
	
func apply(rotation: Vector3, velocity: Vector3, _delta: float) -> Dictionary:
	var direction := input_axis
	var rotated := Basis.from_euler(rotation) * direction

	velocity.x = rotated.x * properties["walk_speed"]
	velocity.z = rotated.z * properties["walk_speed"]
	return {
		"velocity": velocity
	}
