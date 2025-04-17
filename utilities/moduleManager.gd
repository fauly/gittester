@tool
extends Node

signal modules_loaded(module_type: String)
signal all_modules_loaded()
signal module_property_changed(module_type: String, index: int, key: String, new_value)

const TYPE_MOVEMENT = "movement"
const TYPE_CAMERA = "camera"

var movement_modules_dir := "res://Character/Modules/Movement"
var camera_modules_dir := "res://Character/Modules/Camera"

var modules_by_type := {}
var settings_by_module_path := {}

var settings_resource_path := "res://Character/Modules/ModuleSettings.tres"
var settings_resource: ModuleSettings

func _ready() -> void:
	if Engine.is_editor_hint():
		EditorInterface.get_resource_filesystem().connect("filesystem_changed", Callable(self, "_on_filesystem_changed"))
	_load_settings()
	_load_all_modules()

func _on_filesystem_changed():
	refreshModules()

func refreshModules() -> void:
	_load_all_modules()

func _load_settings() -> void:
	if ResourceLoader.exists(settings_resource_path):
		settings_resource = load(settings_resource_path)
	else:
		settings_resource = ModuleSettings.new()
		ResourceSaver.save(settings_resource, settings_resource_path)

func _save_settings() -> void:
	ResourceSaver.save(settings_resource, settings_resource_path)

func _load_all_modules() -> void:
	_load_modules(TYPE_MOVEMENT, movement_modules_dir, "res://Character/Modules/MovementModule.gd")
	emit_signal("modules_loaded", TYPE_MOVEMENT)

	_load_modules(TYPE_CAMERA, camera_modules_dir, "res://Character/Modules/CameraModule.gd")
	emit_signal("modules_loaded", TYPE_CAMERA)

	emit_signal("all_modules_loaded")

func _load_modules(module_type: String, directory: String, base_script_path: String) -> void:
	var modules = []
	var base_script = load(base_script_path)

	var dir = DirAccess.open(ProjectSettings.globalize_path(directory))
	if dir == null:
		push_error("Failed to open directory: " + directory)
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".gd"):
			var script_path = directory + "/" + file_name
			var script = load(script_path)

			if script and script is GDScript and script.get_class() == base_script.get_class():
				var instance = script.new()
				var saved = settings_resource.settings.get(script_path, {})

				# Merge saved settings
				for key in saved.keys():
					instance.properties[key] = saved[key]

				modules.append({
					"instance": instance,
					"path": script_path
				})
		file_name = dir.get_next()
	dir.list_dir_end()

	# Sort, but don't filter out disabled modules (so UI can still show them)
	modules.sort_custom(func(a, b): return a["instance"].properties.get("order", 0) < b["instance"].properties.get("order", 0))
	modules_by_type[module_type] = modules

func getModules(module_type: String) -> Array:
	if not modules_by_type.has(module_type):
		return []
	return modules_by_type[module_type].map(func(m): return m["instance"])

func getModuleProperty(module_type: String, index: int, key: String):
	var module = modules_by_type[module_type][index]["instance"]
	return module.properties.get(key, null)

func setModuleProperty(module_type: String, index: int, key: String, value) -> void:
	var module_data = modules_by_type[module_type][index]
	var instance = module_data["instance"]
	var path = module_data["path"]

	instance.properties[key] = value

	# Update saved settings
	if not settings_resource.settings.has(path):
		settings_resource.settings[path] = {}
	settings_resource.settings[path][key] = value
	_save_settings()

	emit_signal("module_property_changed", module_type, index, key, value)

	if key == "order":
		_sortModules(module_type)

func _sortModules(module_type: String) -> void:
	modules_by_type[module_type].sort_custom(func(a, b): return a["instance"].properties.get("order", 0) < b["instance"].properties.get("order", 0))
