#files.gd
# File utilities for CRUD and parsing
extends Node

# Check a file exists at file_path
func exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)
	
# Open a file and return it at file_path
func open(file_path: String) -> String:
	var file = false
	if exists(file_path):
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
		
# Join the path of a directory and file
func joinPath(dir: String, file: String) -> String:
	if dir.ends_with("/"):
		return dir + file
	else:
		return dir + "/" + file
		
# Clean up a filename to camelcase
func cleanName(file_path: String) -> String:
	# Check if the file exists; if not, log an error and return an empty string.
	if not exists(file_path):
		push_error("File does not exist: " + file_path)
		return ""
	
	# Extract file name (with extension) and the directory path.
	var file_name = file_path.get_file()  # Example: "my file.txt"
	var dir_path = file_path.get_base_dir()
	
	# Split the file name into a base name and an extension.
	var dot_index = file_name.rfind(".")
	var base_name = ""
	var extension = ""
	if dot_index != -1:
		base_name = file_name.substr(0, dot_index)
		extension = file_name.substr(dot_index, file_name.length() - dot_index)
	else:
		base_name = file_name
		extension = ""
	
	# Clean the base name by converting it to camelCase (removes spaces and capitalizes following letters).
	var cleaned_base = ut.camelCase(base_name)
	var new_name = cleaned_base + extension
	
	# If a file with the new name already exists, append an underscore and a 10-digit timestamp.
	if FileAccess.file_exists(joinPath(dir_path, new_name)):
		var timestamp = str(Time.get_unix_time_from_system())  # Unix time is usually a 10-digit number.
		new_name = cleaned_base + "_" + timestamp + extension
	
	return new_name
	
# Open a directory and return its file paths - optionally recursively search
func openDir(directory_path: String, recursive: bool = false) -> Array:
	var files_array: Array = []
	var dir = DirAccess.open(directory_path)
	if dir:
		dir.list_dir_begin()  # Begin listing directory contents
		var entry = dir.get_next()
		while entry != "":
			if entry != "." and entry != "..":  # Skip current and parent directory references
				var full_path = joinPath(directory_path, entry)
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

# Return a parsed version of a file
func parse(json_text: String) -> Variant:
	var json = JSON.new()
	var result = json.parse(json_text)
	if result.error != OK:
		push_error("Error parsing JSON: %s" % json_text)
		return null
	return result.result
