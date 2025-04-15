extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"name": "Gravity",
	"enabled": true,
	"order":100,
	"gravity": 9.8
}

func apply(_rotation: Vector3, velocity: Vector3, delta: float) -> Dictionary:
	if body and not body.is_on_floor():
		velocity.y -= properties["gravity"] * delta

	return {
		"velocity": velocity
	}
