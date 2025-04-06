extends CharacterBody3D

@export var move_speed: float = 5.0
@export var jump_strength: float = 4.5
@export var gravity: float = 9.8
@export var rotation_speed: float = 10.0
@export var rotate_with_movement: bool = true  # Set to false to not rotate when moving

@export_category("Camera Settings")
@export var camera_sensitivity: float = 0.3:
	set(value):
		camera_sensitivity = value
		if camera_pivot and is_instance_valid(camera_pivot):
			camera_pivot.set_sensitivity(value)

@export var camera_invert_y: bool = false:
	set(value):
		camera_invert_y = value
		if camera_pivot and is_instance_valid(camera_pivot):
			camera_pivot.invert_y = value

@export var camera_invert_x: bool = false:
	set(value):
		camera_invert_x = value
		if camera_pivot and is_instance_valid(camera_pivot):
			camera_pivot.invert_x = value

@export_range(2.0, 15.0, 0.5) var camera_distance: float = 5.0:
	set(value):
		camera_distance = value
		if camera_pivot and is_instance_valid(camera_pivot):
			camera_pivot.set_zoom(value)

# The camera is now a sibling node, not a child
var camera_pivot: Node3D

# Internal camera control variables from signals
var camera_horizontal_angle: float = 0
var camera_vertical_angle: float = 0

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity_value = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Find the camera pivot
	camera_pivot = get_parent().get_node_or_null("CameraPivot")
	if not camera_pivot:
		push_error("CameraPivot not found - camera control will be disabled")
		return
	
	# Connect to camera controller signals
	camera_pivot.sensitivity_changed.connect(_on_sensitivity_changed)
	camera_pivot.camera_rotated.connect(_on_camera_rotated)
	camera_pivot.zoom_changed.connect(_on_zoom_changed)
	
	# Initialize camera with player settings
	camera_pivot.set_sensitivity(camera_sensitivity)
	camera_pivot.invert_y = camera_invert_y
	camera_pivot.invert_x = camera_invert_x
	camera_pivot.set_zoom(camera_distance)

func _physics_process(delta):
	# Update camera position to follow player if camera exists
	if camera_pivot and is_instance_valid(camera_pivot):
		camera_pivot.global_position = Vector3(global_position.x, global_position.y + 1.5, global_position.z)
	
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_strength
	
	# Get input direction and handle movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Default movement direction is based on the character's own orientation
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# If we have a camera, use camera-relative movement
	if camera_pivot and is_instance_valid(camera_pivot):
		# Get the camera's forward and right vectors, but ignore Y component
		var camera_basis = camera_pivot.global_transform.basis
		var forward = Vector3(camera_basis.z.x, 0, camera_basis.z.z).normalized() * -1
		var right = Vector3(camera_basis.x.x, 0, camera_basis.x.z).normalized()
		
		# Calculate the movement direction based on camera orientation
		direction = (forward * input_dir.y + right * input_dir.x).normalized()
	
	if direction:
		# Apply horizontal movement - always move relative to camera
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
		
		# Only rotate the character if rotate_with_movement is enabled
		if rotate_with_movement:
			rotate_player_to(direction, delta)
	else:
		# Decelerate when no input
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	
	move_and_slide()

# Separate function for player rotation
func rotate_player_to(direction: Vector3, delta: float) -> void:
	var target_basis = Basis().looking_at(direction, Vector3.UP)
	var target_rotation = Quaternion(transform.basis).slerp(Quaternion(target_basis), rotation_speed * delta)
	transform.basis = Basis(target_rotation)

# Signal handlers
func _on_sensitivity_changed(new_value: float) -> void:
	# Only update if value changed externally (not from this script)
	if new_value != camera_sensitivity:
		camera_sensitivity = new_value

func _on_camera_rotated(horizontal: float, vertical: float) -> void:
	camera_horizontal_angle = horizontal
	camera_vertical_angle = vertical
	# You can use these angles for gameplay mechanics if needed

func _on_zoom_changed(new_zoom: float) -> void:
	# Only update if value changed externally (not from this script)
	if new_zoom != camera_distance:
		camera_distance = new_zoom
		
	# Adjust player speed based on camera distance
	if camera_distance > 7.0:
		move_speed = 7.0  # Move faster when zoomed out
	else:
		move_speed = 5.0  # Normal speed when zoomed in

# Example of how to control the camera from the player
func increase_camera_sensitivity() -> void:
	camera_pivot.set_sensitivity(camera_sensitivity + 0.1) 
