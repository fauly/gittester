@tool
extends "res://character/modules/MovementModule.gd"

@export var properties := {
	"name": "Walk",
	"enabled": true,
	"order": 5,
	"walk_speed": 5.0,
	"acceleration": 15.0,
	"deceleration": 10.0
}

var input_axis := Vector3.ZERO
var pressed := {}
var walk_velocity: Vector3 = Vector3.ZERO

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

func apply(motion_state: Dictionary, delta: float) -> Dictionary:
	var rotation = motion_state.get("rotation", Vector3.ZERO)
	var velocity = motion_state.get("velocity", Vector3.ZERO)

	var basis := Basis.from_euler(rotation)
	var desired = basis * input_axis * properties["walk_speed"]

	var diff = desired - walk_velocity
	var accel = properties["acceleration"] if input_axis.length() > 0 else properties["deceleration"]

	var change = diff.normalized() * accel * delta
	if change.length() > diff.length():
		change = diff

	walk_velocity += change

	# Clamp horizontal movement
	var flat = Vector2(walk_velocity.x, walk_velocity.z)
	if flat.length() > properties["walk_speed"]:
		flat = flat.normalized() * properties["walk_speed"]
		walk_velocity.x = flat.x
		walk_velocity.z = flat.y

	# Update velocity (preserve y component)
	walk_velocity.y = velocity.y
	motion_state["velocity"] = walk_velocity
	return motion_state
