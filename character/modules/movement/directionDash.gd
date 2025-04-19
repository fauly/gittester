@tool
extends "res://character/modules/MovementModule.gd"

# A dash that checks keyboard presses and adds a burst of velocity to the character in that direction

@export var properties := {
    "name": "Direction Dash",
    "enabled": true,
    "order": 10,
    "dash_multiplier": 3.0,
    "dash_duration": 0.2,
    "dash_cooldown": 1.0
}

const MOVE_MAP := {
    "move_forward": Vector3(0, 0, -1),
    "move_back":    Vector3(0, 0,  1),
    "move_left":    Vector3(-1, 0, 0),
    "move_right":   Vector3( 1, 0, 0),
}

var pressed: Dictionary = {}
var input_axis: Vector3 = Vector3.ZERO

var is_dashing := false
var dash_time_left := 0.0
var cooldown_time_left := 0.0
var dash_direction := Vector3.ZERO

func handle_input(action: String, value: Variant):
    if action in MOVE_MAP.keys():
        pressed[action] = value
        _update_input_axis()
        return

    if action == "move_dash" and typeof(value) == TYPE_BOOL and value:
        if not is_dashing and cooldown_time_left <= 0.0:
            is_dashing = true
            dash_time_left = properties["dash_duration"]
            cooldown_time_left = properties["dash_cooldown"]

            if input_axis.length() > 0.0:
                dash_direction = body.global_transform.basis * input_axis.normalized()
            else:
                dash_direction = -body.global_transform.basis.z.normalized()

func _update_input_axis():
    var axis = Vector3.ZERO
    for move_action in MOVE_MAP.keys():
        if pressed.get(move_action, false):
            axis += MOVE_MAP[move_action]
    if axis.length() > 0.0:
        input_axis = axis.normalized()
    else:
        input_axis = Vector3.ZERO

func apply(motion_state: Dictionary, delta: float) -> Dictionary:
    if cooldown_time_left > 0.0:
        cooldown_time_left = max(cooldown_time_left - delta, 0.0)

    var velocity: Vector3 = motion_state.get("velocity", Vector3.ZERO)

    if is_dashing:
        dash_time_left -= delta
        if dash_time_left > 0.0:
            var dash_speed = velocity.length() * (properties["dash_multiplier"] - 1.0)
            velocity += dash_direction * dash_speed
        else:
            is_dashing = false

    motion_state["velocity"] = velocity
    return motion_state
