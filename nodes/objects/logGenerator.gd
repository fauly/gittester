@tool
extends Node3D

# Scene to instance for each log entry
var log_entry_scene: PackedScene = preload("res://nodes/objects/instancing/logEntry.tscn")

func _ready():
	generate_devlog()
	
func _enter_tree():
	generate_devlog()
	
# Directory to look for log entry files
@export var devlog_directory: String = "res://!devlog!/"

# Offset between each log entry (corridor layout)
@export var entry_offset: float = 2.0
@export var aisle_spacing: float = 5.0
@export var inward_angle_deg: float = 15.0

# Optional: max entries to load
@export_range(0, 999, 1) var max_entries: int = 0

# Callable for editor button
@export_tool_button("Generate Logs", "Reload") var regenerate_button = generate_devlog

# Internal references
@onready var logs_root: Node = self
const LogEntry = preload("res://nodes/objects/instancing/logEntry.gd")

func generate_devlog():
	if not logs_root:
		push_warning("logs_root is null, skipping cleanup.")
		return
	
	# Clean up existing log entries
	for child in logs_root.get_children():
		if child is LogEntry:
			logs_root.remove_child(child)
			child.queue_free()

	# Clean filenames
	file.cleanDirFileNames(devlog_directory, true)

	# Gather + parse files
	var file_paths: Array = file.openDir(devlog_directory, true)
	var entries: Array = []

	for file_path in file_paths:
		var content = file.open(file_path)
		var data = file.parse(content)
		if data and data.has("date"):
			entries.append({ "path": file_path, "data": data })
		else:
			push_warning("Skipping file (missing or invalid date): " + file_path)

	# Sort entries by date
	entries.sort_custom(func(a, b):
		var ta = Time.get_unix_time_from_datetime_string(a["data"].get("date", ""))
		var tb = Time.get_unix_time_from_datetime_string(b["data"].get("date", ""))
		return ta > tb
	)

	# Trim to max_entries if needed
	if max_entries > 0:
		entries = entries.slice(0, max_entries)

	# Instance + position
	var index := 0
	var side := 1  # alternate left (-1) / right (1)

	for entry in entries:
		var log_node = log_entry_scene.instantiate()
		log_node.file_path = entry["path"]

		# Compute alternating position
		var x_pos = side * aisle_spacing
		var z_pos = index * entry_offset
		var newPosition = Vector3(x_pos, 3, z_pos)  # lifted and going backwards
		log_node.transform.origin = newPosition

		# Rotate slightly toward center (rotate Y axis)
		var rotation_angle = deg_to_rad(inward_angle_deg * side)  # face inward
		log_node.rotate_y(rotation_angle)

		logs_root.add_child(log_node)

		side *= -1  # flip side
		index += 1
