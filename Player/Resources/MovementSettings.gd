extends Resource
class_name PlayerMovementSettings

# Basic movement
@export var move_speed: float = 5.0
@export var acceleration: float = 30.0  # How quickly player reaches max speed
@export var deceleration: float = 40.0  # How quickly player stops

# Jump parameters
@export var jump_strength: float = 4.5
@export var max_jump_hold_time: float = 0.2  # Shorter hold time for more precise control
@export var jump_add_force: float = 15.0     # Stronger force for more responsive jump
@export var gravity: float = 15.0            # Higher gravity for less floaty feel
@export var fall_gravity_multiplier: float = 1.5  # Fall faster than rise for better feel

# Air control
@export var air_control: float = 0.6  # Multiplier for air movement (0-1)
@export var air_drag: float = 0.03    # Air resistance when in the air

# Rotation
@export var rotation_speed: float = 15.0  # Faster rotation for more responsive feel
@export var rotate_with_movement: bool = true

# Advanced movement
@export var coyote_time: float = 0.1      # Time after leaving edge where jump still works
@export var jump_buffer_time: float = 0.1  # Time before landing where pressing jump will work 
