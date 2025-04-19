@tool
extends EditorPlugin

var debug_window: Control
var tracked_nodes: Array[Node] = []

func _enter_tree():
	debug_window = preload("res://addons/module-debug/debug-window.tscn").instantiate()
	add_control_to_dock(DOCK_SLOT_RIGHT_UL, debug_window)
	debug_window.hide()
	add_tool_menu_item("Module Debugger", _toggle_debug_window)
	get_tree().node_added.connect(_on_node_added)
	get_tree().node_removed.connect(_on_node_removed)

func _exit_tree():
	if get_tree():
		get_tree().node_added.disconnect(_on_node_added)
		get_tree().node_removed.disconnect(_on_node_removed)
	_disconnect_all_nodes()
	remove_control_from_docks(debug_window)
	remove_tool_menu_item("Module Debugger")

func _toggle_debug_window():
	debug_window.visible = not debug_window.visible

func _on_node_added(node: Node) -> void:
	if _is_debuggable_controller(node):
		_connect_controller(node)

func _on_node_removed(node: Node) -> void:
	if tracked_nodes.has(node):
		_disconnect_controller(node)

func _is_debuggable_controller(node: Node) -> bool:
	return (node is MovementController or node is CameraController) and node.has_signal("debug_update")

func _connect_controller(node: Node) -> void:
	if not tracked_nodes.has(node):
		var callable := Callable(debug_window, "update_log")
		if not node.is_connected("debug_update", callable):
			node.connect("debug_update", callable)
			tracked_nodes.append(node)

func _disconnect_controller(node: Node) -> void:
	var callable := Callable(debug_window, "update_log")
	if node.is_connected("debug_update", callable):
		node.disconnect("debug_update", callable)
	tracked_nodes.erase(node)

func _disconnect_all_nodes() -> void:
	for node in tracked_nodes:
		_disconnect_controller(node)
	tracked_nodes.clear()
