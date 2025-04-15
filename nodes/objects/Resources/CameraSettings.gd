extends Resource
class_name CameraSettings

@export var sensitivity: float = 0.3
@export var invert_y: bool = false
@export var invert_x: bool = false
@export var zoom_enabled: bool = true
@export_range(-90.0, 0.0) var min_x_rotation: float = -30.0
@export_range(0.0, 90.0) var max_x_rotation: float = 70.0
@export_range(2.0, 15.0, 0.5) var distance: float = 5.0
@export_range(0.1, 10.0) var distance_min: float = 2.0
@export_range(5.0, 20.0) var distance_max: float = 10.0
@export var zoom_speed: float = 0.5 