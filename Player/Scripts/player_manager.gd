extends Node3D

# Movement variables
@export_category("Movement Settings")
@export var move_speed: float = 5.0:
	set(value):
		move_speed = value
		if character:
			character.move_speed = value

@export var jump_strength: float = 4.5:
	set(value):
		jump_strength = value
		if character:
			character.jump_strength = value

@export var gravity: float = 9.8:
	set(value):
		gravity = value
		if character:
			character.gravity = value

@export var rotation_speed: float = 10.0:
	set(value):
		rotation_speed = value
		if character:
			character.rotation_speed = value

@export var rotate_with_movement: bool = true:
	set(value):
		rotate_with_movement = value
		if character:
			character.rotate_with_movement = value

# Camera variables
@export_category("Camera Settings")
@export var camera_sensitivity: float = 0.3:
	set(value):
		camera_sensitivity = value
		if camera_pivot:
			camera_pivot.mouse_sensitivity = value
		if character:
			character.camera_sensitivity = value

@export var camera_invert_y: bool = false:
	set(value):
		camera_invert_y = value
		if camera_pivot:
			camera_pivot.invert_y = value
		if character:
			character.camera_invert_y = value

@export var camera_invert_x: bool = false:
	set(value):
		camera_invert_x = value
		if camera_pivot:
			camera_pivot.invert_x = value
		if character:
			character.camera_invert_x = value
			
@export var zoom_enabled: bool = true:
	set(value):
		zoom_enabled = value
		if camera_pivot:
			camera_pivot.zoom_enabled = value
		

@export_range(2.0, 15.0, 0.5) var camera_distance: float = 5.0:
	set(value):
		camera_distance = value
		if camera_pivot and camera_pivot.has_method("set_zoom"):
			camera_pivot.set_zoom(value)
		if character:
			character.camera_distance = value

@export_category("Camera Limits")
@export_range(-90.0, 0.0) var min_x_rotation: float = -30.0:
	set(value):
		min_x_rotation = value
		if camera_pivot:
			camera_pivot.min_x_rotation = value

@export_range(0.0, 90.0) var max_x_rotation: float = 70.0:
	set(value):
		max_x_rotation = value
		if camera_pivot:
			camera_pivot.max_x_rotation = value

@export_range(0.1, 10.0) var camera_distance_min: float = 2.0:
	set(value):
		camera_distance_min = value
		if camera_pivot:
			camera_pivot.camera_distance_min = value

@export_range(5.0, 20.0) var camera_distance_max: float = 10.0:
	set(value):
		camera_distance_max = value
		if camera_pivot:
			camera_pivot.camera_distance_max = value

# Node references
var character: CharacterBody3D
var camera_pivot: Node3D

func _ready():
	# Get references to child nodes
	character = $CharacterBody3D
	camera_pivot = $CameraPivot
	
	if not character:
		push_error("CharacterBody3D not found! Player will not function correctly.")
		return
		
	if not camera_pivot:
		push_error("CameraPivot not found! Camera will not function correctly.")
		return
	
	# Apply all settings
	character.move_speed = move_speed
	character.jump_strength = jump_strength
	character.gravity = gravity
	character.rotation_speed = rotation_speed
	character.rotate_with_movement = rotate_with_movement
	
	if camera_pivot:
		camera_pivot.mouse_sensitivity = camera_sensitivity
		camera_pivot.invert_y = camera_invert_y
		camera_pivot.invert_x = camera_invert_x
		camera_pivot.zoom_enabled = zoom_enabled
		camera_pivot.min_x_rotation = min_x_rotation
		camera_pivot.max_x_rotation = max_x_rotation
		camera_pivot.camera_distance_min = camera_distance_min
		camera_pivot.camera_distance_max = camera_distance_max
		
		# Set initial zoom
		if camera_pivot.has_method("set_zoom"):
			camera_pivot.set_zoom(camera_distance)
	
	# Keep character and camera_pivot in sync
	character.camera_sensitivity = camera_sensitivity
	character.camera_invert_y = camera_invert_y
	character.camera_invert_x = camera_invert_x
	character.camera_distance = camera_distance 