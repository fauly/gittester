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
				print(full_path)
				target_array.append(full_path)
		file_name = dir.get_next()

	dir.list_dir_end()


func get_exported_properties_recursive(node: Node) -> Dictionary:
	var result := {}
	for child in node.get_children():
		if not child is Node:
			continue

		var child_data := {}
		var property_list := child.get_property_list()

		for prop in property_list:
			if prop.has("usage") and (prop.usage & PROPERTY_USAGE_EDITOR) and not (prop.usage & PROPERTY_USAGE_CATEGORY):
				var name = prop.name
				child_data[name] = child.get(name)

		if child_data.size() > 0:
			result[child.name] = child_data

	return result
