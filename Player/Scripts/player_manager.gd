extends Node3D

@export_category("Settings")
@export var movement_settings: PlayerMovementSettings
@export var camera_settings: CameraSettings

# Node references
var character: CharacterBody3D
var camera_pivot: Node3D

# For synchronizing values from resources to character and camera
var _syncing: bool = false

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
	
	# Load default settings if none provided
	if not movement_settings:
		movement_settings = load("res://Player/ResourceInstances/DefaultMovementSettings.tres")
	
	if not camera_settings:
		camera_settings = load("res://Player/ResourceInstances/DefaultCameraSettings.tres")
	
	# Apply settings to player and camera
	apply_settings()
	
	# Connect signals for updating values back to settings
	connect_signals()

# Apply all settings to character and camera
func apply_settings() -> void:
	_syncing = true
	
	# Apply movement settings
	if character and movement_settings:
		character.move_speed = movement_settings.move_speed
		character.jump_strength = movement_settings.jump_strength
		character.max_jump_hold_time = movement_settings.max_jump_hold_time
		character.jump_add_force = movement_settings.jump_add_force
		character.gravity = movement_settings.gravity
		character.rotation_speed = movement_settings.rotation_speed
		character.rotate_with_movement = movement_settings.rotate_with_movement
	
	# Apply camera settings
	if camera_pivot and camera_settings:
		camera_pivot.mouse_sensitivity = camera_settings.sensitivity
		camera_pivot.invert_y = camera_settings.invert_y
		camera_pivot.invert_x = camera_settings.invert_x
		camera_pivot.zoom_enabled = camera_settings.zoom_enabled
		camera_pivot.min_x_rotation = camera_settings.min_x_rotation
		camera_pivot.max_x_rotation = camera_settings.max_x_rotation
		camera_pivot.camera_distance_min = camera_settings.distance_min
		camera_pivot.camera_distance_max = camera_settings.distance_max
		camera_pivot.zoom_speed = camera_settings.zoom_speed
		
		# Set initial zoom
		if camera_pivot.has_method("set_zoom"):
			camera_pivot.set_zoom(camera_settings.distance)
	
	# Keep character and camera synchronized
	if character and camera_settings:
		character.camera_sensitivity = camera_settings.sensitivity
		character.camera_invert_y = camera_settings.invert_y 
		character.camera_invert_x = camera_settings.invert_x
		character.camera_distance = camera_settings.distance
	
	_syncing = false

# Connect signals from components to this manager
func connect_signals() -> void:
	if camera_pivot:
		camera_pivot.sensitivity_changed.connect(_on_sensitivity_changed)
		camera_pivot.zoom_changed.connect(_on_zoom_changed)

# Handle changes from the camera and update resources
func _on_sensitivity_changed(value: float) -> void:
	if _syncing or not camera_settings:
		return
	
	camera_settings.sensitivity = value
	
	# Update player if needed
	if character:
		character.camera_sensitivity = value

func _on_zoom_changed(value: float) -> void:
	if _syncing or not camera_settings:
		return
	
	camera_settings.distance = value
	
	# Update player if needed
	if character:
		character.camera_distance = value

# Create and save current settings as a new preset
func save_settings_preset(preset_name: String) -> void:
	var movement_path = "res://Player/Resources/" + preset_name + "_Movement.tres"
	var camera_path = "res://Player/Resources/" + preset_name + "_Camera.tres"
	
	ResourceSaver.save(movement_settings, movement_path)
	ResourceSaver.save(camera_settings, camera_path)
	
	print("Saved settings presets: ", preset_name)

# Load a preset by name
func load_settings_preset(preset_name: String) -> void:
	var movement_path = "res://Player/Resources/" + preset_name + "_Movement.tres"
	var camera_path = "res://Player/Resources/" + preset_name + "_Camera.tres"
	
	var new_movement = ResourceLoader.load(movement_path)
	var new_camera = ResourceLoader.load(camera_path)
	
	if new_movement:
		movement_settings = new_movement
	
	if new_camera:
		camera_settings = new_camera
	
	apply_settings()
	print("Loaded settings preset: ", preset_name)
