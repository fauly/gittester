extends CharacterBody3D

# These will be set by the PlayerManager
@export var move_speed: float = 5.0
@export var acceleration: float = 30.0 
@export var deceleration: float = 40.0
@export var jump_strength: float = 4.5
@export var max_jump_hold_time: float = 0.2
@export var jump_add_force: float = 15.0
@export var gravity: float = 15.0
@export var fall_gravity_multiplier: float = 1.5
@export var air_control: float = 0.6
@export var air_drag: float = 0.03
@export var rotation_speed: float = 15.0
@export var rotate_with_movement: bool = true
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.1

# Camera settings that will be received from CameraPivot
@export var camera_sensitivity: float = 0.3
@export var camera_invert_y: bool = false
@export var camera_invert_x: bool = false
@export var camera_distance: float = 5.0

# Run Function (smooth accel fast decel when released)
@export var run_speed_multiplier: float = 2.0
@export var run_acceleration: float = 3.0
@export var run_deceleration: float = 10.0
var target_speed: float = 0.0
var current_speed: float = 0.0

# The camera is now a sibling node, not a child
var camera_pivot: Node3D

# Jump variables
var is_jumping: bool = false
var jump_hold_timer: float = 0.0
var time_since_grounded: float = 0.0
var buffered_jump: bool = false
var buffered_jump_timer: float = 0.0
var was_on_floor: bool = false

# Internal camera control variables from signals
var camera_horizontal_angle: float = 0
var camera_vertical_angle: float = 0

# Target velocity for smoother acceleration
var target_velocity: Vector3 = Vector3.ZERO




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
	
	# Track time since grounded for coyote time
	if is_on_floor():
		time_since_grounded = 0
		
		# Only reset jumping state when we first land
		if not was_on_floor:
			is_jumping = false
		
		was_on_floor = true
	else:
		time_since_grounded += delta
		was_on_floor = false
	
	# Handle buffered jump input
	if Input.is_action_just_pressed("jump"):
		if not is_on_floor() and time_since_grounded > coyote_time:
			buffered_jump = true
			buffered_jump_timer = 0
	
	# If we landed and had a buffered jump, execute it
	if is_on_floor() and buffered_jump and buffered_jump_timer < jump_buffer_time:
		perform_jump()
		buffered_jump = false
		
	# Count down buffered jump timer
	if buffered_jump:
		buffered_jump_timer += delta
		if buffered_jump_timer >= jump_buffer_time:
			buffered_jump = false
	
	# Handle jumping
	if is_on_floor() or time_since_grounded <= coyote_time:
		# Reset jump state when touching floor
		if not is_jumping and Input.is_action_just_pressed("jump"):
			perform_jump()
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
	
	# Apply appropriate gravity - higher when falling
	var actual_gravity = gravity
	if velocity.y < 0:
		actual_gravity *= fall_gravity_multiplier
	
	velocity.y -= actual_gravity * delta
	
	# Get input direction for movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	
	# Calculate movement direction based on camera orientation
	var direction = get_movement_direction(input_dir)
	
	# Set target velocity based on input
	target_velocity.x = direction.x * current_speed
	target_velocity.z = direction.z * current_speed
	
	# Apply acceleration or deceleration based on input presence
	var horizontal_vel = Vector3(velocity.x, 0, velocity.z)
	var target_horizontal = Vector3(target_velocity.x, 0, target_velocity.z)
	
	var accel_rate = acceleration
	if not is_on_floor():
		accel_rate *= air_control
		
		# Apply air drag (subtle slowdown when not providing input)
		if direction.length() < 0.1:
			horizontal_vel = horizontal_vel.lerp(Vector3.ZERO, air_drag)
	
	if direction.length() > 0.1:
		# Accelerating
		horizontal_vel = horizontal_vel.lerp(target_horizontal, accel_rate * delta)
	else:
		# Decelerating (stopping)
		horizontal_vel = horizontal_vel.lerp(Vector3.ZERO, deceleration * delta)
	
	# Apply the calculated horizontal velocity
	velocity.x = horizontal_vel.x
	velocity.z = horizontal_vel.z
	
	# Rotate player to face movement direction
	if direction.length() > 0.1 and rotate_with_movement:
		rotate_player_to(direction, delta)
	
	# Accel function
	var is_running = Input.is_action_pressed("move_run")
	if is_running:
		target_speed = move_speed * run_speed_multiplier
		current_speed = lerp(current_speed, target_speed, run_acceleration * delta)
	else:
		target_speed = move_speed
		current_speed = lerp(current_speed, target_speed, run_deceleration * delta)
	
	move_and_slide()

func perform_jump():
	is_jumping = true
	jump_hold_timer = 0.0
	velocity.y = jump_strength
	
# Get movement direction based on camera orientation
func get_movement_direction(input_dir: Vector2) -> Vector3:
	# Default movement direction based on character's orientation
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	# If we have a camera, use camera-relative movement
	if camera_pivot and is_instance_valid(camera_pivot):
		# Get the camera's forward and right vectors, but ignore Y component
		var camera_basis = camera_pivot.global_transform.basis
		# Forward is the negative Z direction in camera's local space
		var forward = (Vector3(camera_basis.z.x, 0, camera_basis.z.z).normalized())*-1
		var right = Vector3(camera_basis.x.x, 0, camera_basis.x.z).normalized()
		
		# Calculate the movement direction based on camera orientation
		direction = (forward * -input_dir.y + right * input_dir.x).normalized()
	
	return direction

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
