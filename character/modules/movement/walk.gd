extends MovementModule

@export var walk_speed: float = 5.0
var input_axis := Vector3.ZERO

func handle_input(action: String, value: Variant):
	if action == "move":
		input_axis = value

func apply(velocity: Vector3, delta: float) -> Vector3:
	var v = velocity
	v.x = input_axis.x * walk_speed
	v.z = input_axis.z * walk_speed
	return v
