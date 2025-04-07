#files.gd
# File utilities for CRUD and parsing
extends Node

func exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)
	

func open(file_path: String) -> String:
	var file = false
	if file.exists(file_path):
		var err = file.open(file_path, FileAccess.READ)
		if err == OK:
			var content = file.get_as_text()
			file.close()
			return content
		else:
			push_error("Failed to open file: %s" % file_path)
			return ""
	else:
		push_error("File not found: %s" % file_path)
		return ""

func parse(json_text: String) -> Variant:
	var json = JSON.new()
	var result = json.parse(json_text)
	if result.error != OK:
		push_error("Error parsing JSON: %s" % json_text)
		return null
	return result.result
