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

func loadModulesFromDir(parent: Node, dir_path: String, base_script_path: String, target_array: Array):
	var base_script := load(base_script_path)
	if base_script == null:
		push_error("Could not load base module script: " + base_script_path)
		return

	# Remove previous instances that match the base
	for child in parent.get_children():
		if child.has_method("get_script") and child.get_script() and child.get_script().get_base_script() == base_script:
			parent.remove_child(child)
			child.queue_free()

	target_array.clear()

	var paths: Array = []
	ut.appendDir(dir_path, paths, "*.gd")

	for path in paths:
		var script = load(path)
		if script and script is GDScript:
			var node := Node.new()
			node.set_script(script)

			if node.get_script() and node.get_script().get_base_script() == base_script:
				parent.add_child(node)
				target_array.append(node)
				print("✔ Loaded module:", path)


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
				#print(full_path)
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
				var propertyName = prop.name
				child_data[propertyName] = child.get(propertyName)

		if child_data.size() > 0:
			result[child.propertyName] = child_data

	return result
