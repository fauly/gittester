@tool
extends Panel
class_name ModuleManagerUI

const TYPE_MOVEMENT = "movement"
const TYPE_CAMERA = "camera"

var tab_container: TabContainer
var refresh_button: Button
var module_lists := {}

func _ready() -> void:
	_build_ui()
	if Engine.is_editor_hint():
		ModuleManager.connect("modules_loaded", _on_module_type_loaded)
		ModuleManager.connect("module_property_changed", _on_property_changed_signal)
	ModuleManager.refreshModules()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()

	refresh_button = Button.new()
	refresh_button.text = "Refresh Modules"
	refresh_button.custom_minimum_size = Vector2(150, 30)
	refresh_button.connect("pressed", _on_refresh_pressed)
	add_child(refresh_button)

	tab_container = TabContainer.new()
	tab_container.name = "ModuleTabs"
	tab_container.anchor_right = 1.0
	tab_container.anchor_bottom = 1.0
	add_child(tab_container)

	_create_tab(TYPE_MOVEMENT)
	_create_tab(TYPE_CAMERA)

func _create_tab(module_type: String) -> void:
	var panel = PanelContainer.new()
	panel.name = module_type.capitalize() + "Modules"

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL

	module_lists[module_type] = vbox

	scroll.add_child(vbox)
	panel.add_child(scroll)

	tab_container.add_child(panel)
	tab_container.set_tab_title(tab_container.get_child_count() - 1, module_type.capitalize())

func _update_tab(module_type: String) -> void:
	if not module_lists.has(module_type):
		push_warning("No ModuleList stored for: " + module_type)
		return

	var vbox = module_lists[module_type]
	var modules = ModuleManager.getModules(module_type)
	if not modules:
		return

	for child in vbox.get_children():
		child.queue_free()

	for i in range(modules.size()):
		var mod = modules[i]
		var mod_panel = VBoxContainer.new()
		mod_panel.name = "Module_%d" % i

		# Collapsible header area (placeholder UI)
		var header = HBoxContainer.new()
		var toggle = CheckBox.new()
		toggle.text = "[%d] %s" % [i, mod.properties.get("name", "Unnamed")]
		toggle.button_pressed = mod.properties.get("enabled", true)
		toggle.connect("toggled", Callable(self, "_on_property_changed_gui").bind(module_type, i, "enabled"))
		header.add_child(toggle)

		mod_panel.add_child(header)

		if mod.properties.get("enabled", true):
			for key in mod.properties.keys():
				if key == "name" or key == "enabled":
					continue
				var hbox = HBoxContainer.new()
				var key_label = Label.new()
				key_label.text = key + ":"
				hbox.add_child(key_label)

				var editor = _create_edit_control(module_type, i, key, mod.properties[key])
				hbox.add_child(editor)
				mod_panel.add_child(hbox)

		vbox.add_child(mod_panel)

func _create_edit_control(module_type: String, index: int, key: String, current_value: Variant) -> Control:
	var control: Control
	var callback = Callable(self, "_on_property_changed_gui").bind(module_type, index, key)
	match typeof(current_value):
		TYPE_BOOL:
			control = CheckBox.new()
			control.button_pressed = current_value
			control.connect("toggled", callback)
		TYPE_INT, TYPE_FLOAT:
			control = SpinBox.new()
			control.value = current_value
			control.step = 0.1
			control.min_value = -10000
			control.max_value = 10000   
			control.allow_greater = true
			control.allow_lesser = true
			control.connect("value_changed", callback)
		_:
			control = LineEdit.new()
			control.text = str(current_value)
			control.connect("text_changed", callback)
	return control

func _on_property_changed_gui(new_value, module_type: String, index: int, key: String) -> void:
	ModuleManager.setModuleProperty(module_type, index, key, new_value)

func _on_property_changed_signal(module_type: String, index: int, key: String, value: Variant) -> void:
	_update_tab(module_type)

func _on_module_type_loaded(module_type: String) -> void:
	_update_tab(module_type)

func _on_refresh_pressed() -> void:
	ModuleManager.refreshModules()
