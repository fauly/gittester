extends Node

@export var moduleType: String = "movement"
@export var enabled: bool = true
@export var priority: int = 0

func apply(velocity: Vector3, _delta: float) -> Vector3:
	return velocity

func handle_input(_action: String, _value: Variant) -> void:
	pass
