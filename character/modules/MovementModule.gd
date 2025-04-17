@tool
extends Node

var body: PhysicsBody3D

func apply(motion_state: Dictionary, _delta: float) -> Dictionary:
	return motion_state

func handle_input(_action: String, _value: Variant) -> void:
	pass
