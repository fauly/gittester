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

func appendDir(directory_path: String, target_array: Array, match_regex: String = "") -> void:
	var dir = DirAccess.open(ProjectSettings.globalize_path(directory_path))
	if dir == null:
		push_error("Failed to initialize DirAccess for: " + directory_path)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			var full_path = directory_path + "/" + file_name
			if match_regex == "" or file_name.matchn(match_regex):
				target_array.append(full_path)
		file_name = dir.get_next()

	dir.list_dir_end()
