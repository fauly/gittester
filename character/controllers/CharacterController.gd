extends Node3D

@onready var body: CharacterBody3D = $CharacterBody3D
@onready var movement: MovementController = $MovementController

func _physics_process(delta: float):
	movement._physics_process(delta)

	body.velocity = movement.velocity
	body.move_and_slide()
