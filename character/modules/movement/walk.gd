@tool
extends "res://character/modules/MovementModule.gd"

@export var properties := {
	"name": "Walk",
	"enabled": true,
	"order": 5,
	"walk_speed": 5.0,
	"acceleration": 15.0,
	"deceleration": 40.0
}

const MOVE_MAP := {
	"move_forward": Vector3(0, 0, -1),
	"move_back":    Vector3(0, 0,  1),
	"move_left":    Vector3(-1, 0, 0),
	"move_right":   Vector3( 1, 0, 0),
}

var pressed := {}
var input_axis := Vector3.ZERO

var walk_velocity_contrib := Vector2.ZERO

func handle_input(action: String, value: Variant):
	if action in MOVE_MAP:
		pressed[action] = value
		_update_input_axis()

func _update_input_axis():
	var axis = Vector3.ZERO
	for a in MOVE_MAP.keys():
		if pressed.get(a, false):
			axis += MOVE_MAP[a]
	input_axis = axis.normalized() if axis.length_squared() > 0.0 else Vector3.ZERO

func apply(motion_state: Dictionary, delta: float) -> Dictionary:
	# 1 Grab the full velocity so far (including dash, gravity, etc.)
	var velocity: Vector3 = motion_state.get("velocity", Vector3.ZERO)

	# 2 Compute world‑space desired walk velocity (horizontal only)
	var rot = motion_state.get("rotation", Vector3.ZERO)
	var basis = Basis.from_euler(rot)
	var world_input = basis * input_axis  # local→world
	var desired = Vector2(world_input.x, world_input.z) * properties["walk_speed"]

	# 3 Keep track of the old contrib so we can diff it out
	var old = walk_velocity_contrib

	# 4 Accelerate or decelerate walk_velocity_contrib toward desired
	var rate = properties["acceleration"] if input_axis.length() > 0.0 else properties["deceleration"]
	walk_velocity_contrib = walk_velocity_contrib.move_toward(desired, rate * delta)

	# 5 Compute the *change* this frame
	var delta_contrib = walk_velocity_contrib - old

	# 6 Apply only that delta to the motion_state
	velocity.x += delta_contrib.x
	velocity.z += delta_contrib.y

	# 7 Write back
	motion_state["velocity"] = velocity
	return motion_state
