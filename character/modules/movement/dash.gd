extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"name": "Dash",
	"enabled": true,
	"order": 10,
	"dash_multiplier": 3.0,
	"dash_duration": 0.2,
	"dash_cooldown": 1.0
}

var is_dashing := false
var dash_time_left := 0.0
var cooldown_time_left := 0.0
var last_dash_direction := Vector3.ZERO

func handle_input(action: String, value: Variant):
	if action == "move_dash" and typeof(value) == TYPE_BOOL and value == true:
		if not is_dashing and cooldown_time_left <= 0.0:
			is_dashing = true
			dash_time_left = properties["dash_duration"]
			cooldown_time_left = properties["dash_cooldown"]

func apply(_rotation: Vector3, velocity: Vector3, delta: float) -> Dictionary:
	if cooldown_time_left > 0.0:
		cooldown_time_left -= delta

	var contribution := Vector3.ZERO

	if is_dashing:
		dash_time_left -= delta
		if dash_time_left > 0.0:
			var horiz = velocity
			horiz.y = 0
			if horiz.length() > 0:
				last_dash_direction = horiz.normalized()

			# Apply boost in direction of movement
			contribution = last_dash_direction * horiz.length() * (properties["dash_multiplier"] - 1.0)
		else:
			is_dashing = false

	return {
		"velocity": contribution
	}
