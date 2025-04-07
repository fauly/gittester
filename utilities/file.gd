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
		
func join_path(dir: String, file: String) -> String:
	if dir.ends_with("/"):
		return dir + file
	else:
		return dir + "/" + file


func openDir(directory_path: String, recursive: bool = false) -> Array:
	var files_array: Array = []
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()  # Begin listing directory contents
		var entry = dir.get_next()
		while entry != "":
			if entry != "." and entry != "..":  # Skip current and parent directory references
				var full_path = join_path(directory_path, entry)
				if dir.current_is_dir():
					if recursive:
						# Recursively gather files from the subdirectory
						files_array.append_array(openDir(full_path, true))
					#else:
						 #Optionally add the directory path or skip it
						 #files_array.append(full_path)
				else:
					files_array.append(full_path)
			entry = dir.get_next()
		dir.list_dir_end()
	else:
		push_error("Failed to open directory: " + directory_path)
	return files_array


func parse(json_text: String) -> Variant:
	var json = JSON.new()
	var result = json.parse(json_text)
	if result.error != OK:
		push_error("Error parsing JSON: %s" % json_text)
		return null
	return result.result
