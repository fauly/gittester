extends Node3D

# Define signals to expose camera properties
signal sensitivity_changed(new_value)
signal camera_rotated(horizontal_angle, vertical_angle)
signal zoom_changed(new_zoom)

# These will be set by the PlayerManager
@export var mouse_sensitivity: float = 0.3
@export var invert_y: bool = false
@export var invert_x: bool = false
@export var zoom_enabled: bool = true
@export var min_x_rotation: float = -30.0
@export var max_x_rotation: float = 70.0
@export var camera_distance_min: float = 2.0
@export var camera_distance_max: float = 10.0
@export var zoom_speed: float = 0.5

# These will be set in _ready
var spring_arm: SpringArm3D
var camera: Camera3D

# Current rotation values
var rotation_x: float = 0
var rotation_y: float = 0

func _ready():
	# Get references to nodes
	spring_arm = $SpringArm3D
	if not spring_arm:
		push_error("SpringArm3D node not found - camera functionality will be limited")
		return
		
	camera = $SpringArm3D/Camera3D
	if not camera:
		push_error("Camera3D node not found - camera functionality will be limited")
	
	# Reset the camera position
	rotation_x = 0
	rotation_y = 0
	
	# Apply initial rotation
	transform.basis = Basis()
	rotate_object_local(Vector3.UP, rotation_y)
	spring_arm.rotation.x = rotation_x
	
	# Capture mouse for camera control
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta):
	# Skip if spring arm is not available
	if not spring_arm:
		return
	
	# We'll handle camera rotation in _input for mouse motion
	# Just emit the current rotation angles each frame
	camera_rotated.emit(rotation_y, rotation_x)

func _input(event):
	# Skip if spring arm is not available
	if not spring_arm:
		return
	
	# Toggle mouse capture with Escape key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Handle mouse motion for camera rotation
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Process X (horizontal) rotation
		var x_factor = -1.0 if invert_x else 1.0
		rotation_y += event.relative.x * mouse_sensitivity * 0.01 * x_factor
		
		# Process Y (vertical) rotation
		var y_factor = -1.0 if invert_y else 1.0
		rotation_x += event.relative.y * mouse_sensitivity * 0.01 * y_factor
		
		# Clamp vertical rotation to avoid flipping
		rotation_x = clamp(rotation_x, deg_to_rad(min_x_rotation), deg_to_rad(max_x_rotation))
		
		# Apply the rotation
		transform.basis = Basis()
		rotate_object_local(Vector3.UP, rotation_y)
		spring_arm.rotation.x = rotation_x
	
	# Handle mouse wheel for zoom
	if event is InputEventMouseButton and zoom_enabled:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			set_zoom(spring_arm.spring_length - zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			set_zoom(spring_arm.spring_length + zoom_speed)

# Method to change sensitivity externally
func set_sensitivity(value: float) -> void:
	mouse_sensitivity = value
	sensitivity_changed.emit(value)

# Method to change zoom externally
func set_zoom(value: float) -> void:
	if not spring_arm:
		return
		
	var new_zoom = clamp(value, camera_distance_min, camera_distance_max)
	if spring_arm.spring_length != new_zoom:
		spring_arm.spring_length = new_zoom
		zoom_changed.emit(spring_arm.spring_length)

# Get current camera direction
func get_camera_direction() -> Vector3:
	if not camera:
		return Vector3.FORWARD.normalized() * -1
	return -camera.global_transform.basis.z 
