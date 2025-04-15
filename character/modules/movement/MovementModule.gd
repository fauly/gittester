extends Node

@export var enabled: bool = true
@export var order: int = 0
@onready var parent := get_parent() 
@onready var body : PhysicsBody3D = parent.myTarget
func apply(rotation: Vector3, velocity: Vector3, _delta: float) -> Dictionary:
	return {
		"rotation": rotation,
		"velocity": velocity
	}

func handle_input(_action: String, _value: Variant) -> void:
	pass
