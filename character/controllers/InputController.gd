extends Node
class_name InputController

var targets: Array[Node] = []

func register_target(node: Node) -> void:
	if node and not targets.has(node):
		targets.append(node)

func unregister_target(node: Node) -> void:
	targets.erase(node)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_emit("look", event.relative)

	elif event is InputEventJoypadMotion:
		_emit("joy_axis_" + str(event.axis), event.axis_value)

	elif event is InputEventKey:
		_emit("key_" + str(event.physical_keycode), event.pressed)

func _process(_delta: float) -> void:
	for action in InputMap.get_actions():
		if Input.is_action_just_pressed(action):
			_emit(action, true)
		elif Input.is_action_just_released(action):
			_emit(action, false)
		else:
			var strength := Input.get_action_strength(action)
			if strength > 0:
				_emit(action, strength)

func _emit(action: String, value: Variant):
	for target in targets:
		if target and target.has_method("handle_input"):
			target.call_deferred("handle_input", action, value)
