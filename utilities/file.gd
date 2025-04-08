#files.gd
# File utilities for CRUD and parsing
@tool
extends Node

var dir_access: DirAccess = null

func _ready():
	# Instantiate DirAccess for the project's root directory.
	# This means all file operations will remain relative to res://
	dir_access = DirAccess.open(ProjectSettings.globalize_path("res://"))
	if dir_access == null:
		push_error("Failed to initialize DirAccess for res://")

# Check a file exists at file_path
func exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)
	
# Open a file and return it at file_path
func open(file_path: String) -> String:
	if not exists(file_path):
		push_error("File not found: %s" % file_path)
		return ""

	var file := FileAccess.open(file_path, FileAccess.READ)
	if file:
		var content := file.get_as_text()
		file.close()
		return content
	else:
		push_error("Failed to open file: %s" % file_path)
		return ""
		
# Join the path of a directory and file
func joinPath(dir: String, file: String) -> String:
	if dir.ends_with("/"):
		return dir + file
	else:
		return dir + "/" + file
		
# Clean up a filename to camelcase
func cleanName(file_path: String) -> String:
	if not exists(file_path):
		push_error("❌ File not found: " + file_path)
		return ""

	var file_name := file_path.get_file()
	var dir_path := file_path.get_base_dir()

	# Load and parse the file for the date
	var content := open(file_path)
	var data: Variant = parse(content)

	if data == null or not data.has("date"):
		push_error("❌ Missing or invalid 'date' in: " + file_path)
		return file_name

	var dt = data["date"]  # "2025-04-08 09:11"
	var parts = dt.split(" ")
	if parts.size() != 2:
		push_error("❌ Invalid date format in: " + file_path)
		return file_name

	var date_str = parts[0].replace("-", "")  # 20250408
	var time_str = parts[1].replace(":", "")  # 0911
	var correct_suffix = "_" + date_str + "_" + time_str

	# Split base + extension
	var dot_index := file_name.rfind(".")
	var base_name := file_name.substr(0, dot_index) if dot_index != -1 else file_name
	var extension := file_name.substr(dot_index) if dot_index != -1 else ""

	var parts_base := base_name.split("_")

	# Case 1: More than 3 parts → always clean
	if parts_base.size() > 3:
		pass

	# Case 2: Exactly 3 parts → check if the last two match date
	elif parts_base.size() == 3:
		var suffix_date = parts_base[1]
		var suffix_time = parts_base[2]
		if suffix_date == date_str and suffix_time == time_str:
			#print("✅ Already correct:", file_name)
			return file_name

	# In both cases above, fallback to first part and rebuild
	var clean_base := ut.camelCase(parts_base[0])
	var expected_name: String= clean_base + correct_suffix + extension
	var new_full_path := joinPath(dir_path, expected_name)

	print("file:", file_name, "\nexpected:", expected_name)

	var err := DirAccess.rename_absolute(file_path, new_full_path)
	if err != OK:
		push_error("❌ Failed to rename: " + file_path + " to " + new_full_path)
	else:
		print("✅ Renamed:", file_path, "→", new_full_path)

	return expected_name

func cleanDirFileNames(directory_path: String, recursive: bool = false) -> void:
	print("📁 Cleaning directory:", directory_path, " | Recursive:", recursive)
	var files_array = openDir(directory_path, recursive)
	#print("📄 Found ", files_array.size(), " files")
	for file_path in files_array:
		cleanName(file_path)
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().scan()

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

# Return a parsed version of a JSON string
func parse(json_text: String) -> Variant:
	var json := JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		var error_message := json.get_error_message()
		var error_line := json.get_error_line()
		push_error("JSON parse error: %s at line %d" % [error_message, error_line])
		return null
	return json.get_data()
