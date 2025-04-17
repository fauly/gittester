@tool
extends EditorPlugin

var debug_window: Control

func _enter_tree():
	debug_window = preload("res://addons/module-debug/debug-window.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, debug_window)
	debug_window.hide()
	add_tool_menu_item("Module Debugger", _toggle_debug_window)
	set_process(true) 

func _exit_tree():
	remove_control_from_docks(debug_window)
	remove_tool_menu_item("Module Debugger")
	set_process(false)

func _toggle_debug_window():
	debug_window.visible = not debug_window.visible

var connected = false

func _process(_delta):
	#print('proc')
	#if Engine.is_editor_hint():
		#return
	#print('editor')

	if not debug_window:
		return
	#print('window')

	var root := get_tree().root
	if not connected:
		_connect_debuggable_controllers(root)

func _connect_debuggable_controllers(root_node: Node):
	for node in root_node.get_children(true):
		if node is MovementController or node is CameraController:
			if node.has_signal("debug_update"):
				var callable := Callable(debug_window, "update_log")
				if not node.is_connected("debug_update", callable):
					node.connect("debug_update", callable)
					connected = true
		_connect_debuggable_controllers(node)
