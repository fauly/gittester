@tool
extends EditorInspectorPlugin

func can_handle(object):
	return object is MovementController

func parse_begin(object):
	if not object.has("modules"):
		return

	var modules = object.modules
	for module in modules:
		if not is_instance_valid(module):
			continue
		if not module.has("properties"):
			continue

		var group_name = module.name if module.name != "" else module.get_class()
		var properties: Dictionary = module.properties

		# Collapsible container
		var outer = VBoxContainer.new()
		outer.name = group_name

		# Fold toggle
		var header_btn = Button.new()
		header_btn.text = "▼  %s".format([group_name])
		header_btn.flat = true
		header_btn.focus_mode = Control.FOCUS_NONE
		header_btn.toggle_mode = true
		header_btn.pressed = true

		var inner = VBoxContainer.new()
		inner.name = "inner_%s" % group_name
		inner.visible = true
		inner.set_h_size_flags(Control.SIZE_EXPAND_FILL)

		header_btn.connect("toggled", func(toggled):
			inner.visible = toggled
			header_btn.text = ("▼ " if toggled else "► ") + group_name

		)

		outer.add_child(header_btn)
		outer.add_child(inner)

		# Add properties inside collapsible group
		for key in properties.keys():
			var value = properties[key]
			var row = HBoxContainer.new()
			var key_label = Label.new()
			key_label.text = key + ":"
			key_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			key_label.custom_minimum_size.x = 100

			var editor = _make_editor(value)
			if editor:
				editor.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				editor.connect("value_changed", _on_value_changed.bind(module, key))
				row.add_child(key_label)
				row.add_child(editor)
				inner.add_child(row)

		add_custom_control(outer)

func _on_value_changed(value, module, key):
	if module.has("properties"):
		module.properties[key] = value
		module.property_list_changed_notify()

func _make_editor(value):
	match typeof(value):
		TYPE_FLOAT:
			var spin = SpinBox.new()
			spin.min_value = -999999
			spin.max_value = 999999
			spin.step = 0.01
			spin.value = value
			return spin
		TYPE_INT:
			var spin = SpinBox.new()
			spin.min_value = -999999
			spin.max_value = 999999
			spin.step = 1
			spin.value = value
			return spin
		TYPE_BOOL:
			var checkbox = CheckBox.new()
			checkbox.button_pressed = value
			checkbox.connect("toggled", _on_value_changed.bind(value))
			return checkbox
		TYPE_STRING:
			var line_edit = LineEdit.new()
			line_edit.text = value
			line_edit.connect("text_changed", _on_value_changed.bind(value))
			return line_edit
		_:
			return null
