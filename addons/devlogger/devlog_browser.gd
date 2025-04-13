@tool
extends EditorPlugin

var devlog_browser_dock: Control = null



func _enter_tree():
	var scene = load("res://addons/devlogger/devlog_browser.tscn")
	if scene:
		devlog_browser_dock = scene.instantiate()
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, devlog_browser_dock)
		devlog_browser_dock.name = "Devlog"
	else:
		push_error("Failed to load Devlog Browser scene!")

func _exit_tree():
	if devlog_browser_dock and is_instance_valid(devlog_browser_dock):
		remove_control_from_docks(devlog_browser_dock)
		devlog_browser_dock.queue_free()
