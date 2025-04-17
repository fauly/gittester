@tool
extends "res://character/modules/MovementModule.gd"

@export var properties := {
	"name": "Gravity",
	"enabled": true,
	"order": 100,
	"gravity": 9.8
}

func apply(motion_state: Dictionary, delta: float) -> Dictionary:
	if body and not body.is_on_floor():
		motion_state["velocity"].y -= properties["gravity"] * delta
	return motion_state
