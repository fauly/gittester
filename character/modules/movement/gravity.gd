extends "res://character/modules/movement/MovementModule.gd"

@export var properties := {
	"enabled": true,
	"gravity": 9.8
}

func apply(velocity: Vector3, delta: float) -> Vector3:
	velocity.y -= properties['gravity'] * delta
	return velocity
