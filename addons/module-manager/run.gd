@tool
extends EditorPlugin

var ui_panel: ModuleManagerUI = null

func _enter_tree():
	# Only create and add the dock if it hasn't been added already.
	if not ui_panel:
		ui_panel = preload("res://addons/module-manager/ModuleManagerUI.gd").new()
		ui_panel.name = "Modules"  # Make sure the name is not empty.
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, ui_panel)

func _exit_tree():
	if ui_panel and ui_panel.get_parent():
		remove_control_from_docks(ui_panel)
		ui_panel.free()
		ui_panel = null
