@tool
extends EditorPlugin

var datetime_shortcut := Shortcut.new()

func _enter_tree():
	add_tool_menu_item("Insert DateTime", Callable(self, "insert_datetime"))

func _exit_tree():
	remove_tool_menu_item("Insert DateTime")

func insert_datetime():
	var editor_interface = get_editor_interface()
	var script_editor = editor_interface.get_script_editor()
	if script_editor:
		var text_editor = script_editor.get_current_editor()
		if text_editor:
			var dt = Time.get_datetime_dict_from_system()
			var formatted = "%04d-%02d-%02d %02d:%02d:%02d" % [
				dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second
			]
			text_editor.insert_text_at_cursor(formatted)
		else:
			print("No active text editor found.")
	else:
		print("Script editor not available.")
