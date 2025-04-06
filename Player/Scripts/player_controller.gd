extends CharacterBody3D

# These will be set by the PlayerManager
@export var move_speed: float = 5.0
@export var jump_strength: float = 4.5
@export var max_jump_hold_time: float = 0.4   # Maximum time to add extra force
@export var jump_add_force: float = 12.0      # Force added while holding jump
@export var gravity: float = 9.8
@export var rotation_speed: float = 10.0
@export var rotate_with_movement: bool = true

# Camera settings that will be received from CameraPivot
@export var camera_sensitivity: float = 0.3
@export var camera_invert_y: bool = false
@export var camera_invert_x: bool = false
@export var camera_distance: float = 5.0

# The camera is now a sibling node, not a child
var camera_pivot: Node3D

# Jump variables
var is_jumping: bool = false
var jump_hold_timer: float = 0.0

# Internal camera control variables from signals
var camera_horizontal_angle: float = 0
var camera_vertical_angle: float = 0

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

func _physics_process(delta):
	# Update camera position to follow player if camera exists
	if camera_pivot and is_instance_valid(camera_pivot):
		camera_pivot.global_position = Vector3(global_position.x, global_position.y + 1.5, global_position.z)
	
	# Handle jumping
	if is_on_floor():
		# Reset jump state when touching floor
		is_jumping = false
		jump_hold_timer = 0.0
		
		# Begin a new jump
		if Input.is_action_just_pressed("jump"):
			is_jumping = true
			velocity.y = jump_strength  # Initial jump force
	else:
		# Add more force while holding space during a jump
		if is_jumping and Input.is_action_pressed("jump"):
			if jump_hold_timer < max_jump_hold_time:
				# Use sine wave for smoother force reduction (starts at 1, ends at 0)
				var time_progress = jump_hold_timer / max_jump_hold_time
				var force_factor = sin((1.0 - time_progress) * PI/2)
				
				# Apply the extra force with the sine wave factor
				velocity.y += jump_add_force * force_factor * delta
				jump_hold_timer += delta
		else:
			# Jump height control ends when button is released
			is_jumping = false
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Get input direction and handle movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Default movement direction is based on the character's own orientation
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# If we have a camera, use camera-relative movement
	if camera_pivot and is_instance_valid(camera_pivot):
		# Get the camera's forward and right vectors, but ignore Y component
		var camera_basis = camera_pivot.global_transform.basis
		# Forward is the negative Z direction in camera's local space
		var forward = (Vector3(camera_basis.z.x, 0, camera_basis.z.z).normalized())*-1
		var right = Vector3(camera_basis.x.x, 0, camera_basis.x.z).normalized()
		
		# Calculate the movement direction based on camera orientation
		# For input_dir.y, positive is forward (W key), negative is backward (S key)
		# We negate the forward vector for input_dir.y to get the correct direction
		direction = (forward * -input_dir.y + right * input_dir.x).normalized()
	
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
	camera_sensitivity = new_value

func _on_camera_rotated(horizontal: float, vertical: float) -> void:
	camera_horizontal_angle = horizontal
	camera_vertical_angle = vertical

func _on_zoom_changed(new_zoom: float) -> void:
	camera_distance = new_zoom

# Example of how to control the camera from the player
func increase_camera_sensitivity() -> void:
	camera_pivot.set_sensitivity(camera_sensitivity + 0.1) 
