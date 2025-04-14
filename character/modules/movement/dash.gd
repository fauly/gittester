extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"name": "Dash",
	"enabled": true,
	"dash_speed": 12.0,
	"dash_duration": 0.2,
	"dash_cooldown": 1.0
}

var is_dashing := false
var dash_time_left := 0.0
var cooldown_time_left := 0.0
var dash_direction := Vector3.ZERO

func handle_input(action: String, value: Variant):
	if action == "move_dash" and value == true and not is_dashing and cooldown_time_left <= 0.0:
		if body:
			dash_direction = -body.transform.basis.z.normalized()
			is_dashing = true
			dash_time_left = properties["dash_duration"]
			cooldown_time_left = properties["dash_cooldown"]

func apply(_rotation: Vector3, velocity: Vector3, delta: float) -> Dictionary:
	if cooldown_time_left > 0.0:
		cooldown_time_left -= delta

	if is_dashing:
		dash_time_left -= delta
		if dash_time_left > 0.0:
			velocity.x = dash_direction.x * properties["dash_speed"]
			velocity.z = dash_direction.z * properties["dash_speed"]
		else:
			is_dashing = false

	return {
		"velocity": velocity
	}
