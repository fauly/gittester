@tool
extends Node

func camelCase(nameToChange: String) -> String:
	var parts = nameToChange.split(" ", false)
	if parts.size() == 0:
		return nameToChange
	var result = parts[0]
	for i in range(1, parts.size()):
		result += parts[i].capitalize()
	return result

func appendDir(directory_path: String, target_array: Array) -> void:
	var dir = DirAccess.open(ProjectSettings.globalize_path("res://"))
	if dir == null:
		push_error("Failed to initialize DirAccess for res://")

	dir.list_dir_begin()
	
	var file_name = dir.get_next()
	while file_name != "":
		# Form the full path for the file.
		var full_path = directory_path + "/" + file_name
		# Check that the current item is not a directory.
		if not dir.current_is_dir():
			target_array.append(full_path)
		file_name = dir.get_next()
	
	dir.list_dir_end()
