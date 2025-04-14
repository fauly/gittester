@tool
extends EditorPlugin

var modulePropertyExporter : EditorInspectorPlugin = null

func _enter_tree():
	var palette = get_editor_interface().get_command_palette()
	palette.add_command("Insert DateTime", "fauly_insert_datetime", Callable(self, "insert_datetime"),"Ctrl+D")

	print("Reloaded fauly-utilities")

	# Register inspector plugin
	modulePropertyExporter = preload("res://addons/fauly-utilities/modulePropertyExporter.gd").new()
	add_inspector_plugin(modulePropertyExporter)

func _exit_tree():
	var palette = get_editor_interface().get_command_palette()
	palette.remove_command("fauly_insert_datetime")

	if modulePropertyExporter:
		remove_inspector_plugin(modulePropertyExporter)

func insert_datetime() -> bool:
	var dt = Time.get_datetime_dict_from_system()
	var formatted = "%04d-%02d-%02d %02d:%02d:%02d" % [
		dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second
	]

	var editor = get_editor_interface().get_script_editor().get_current_editor().get_base_editor()

	if editor:
		editor.insert_text_at_caret(formatted)
		return true
	else:
		print("No editor found to insert datetime.")
		return false
