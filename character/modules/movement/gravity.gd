extends MovementModule

@export var properties := {
	"enabled": true,
	"gravity": 9.8
}

func apply(velocity: Vector3, delta: float) -> Vector3:
	velocity.y -= properties['gravity'] * delta
	return velocity
