@tool
extends VBoxContainer

@onready var new_entry_button: Button = $TopBar/NewEntryButton
@onready var delete_button: Button = $TopBar/DeleteButton
@onready var entry_tree: Tree = $EntryTree
@onready var content_preview: TextEdit = $ContentPreview
@onready var save_dialog: FileDialog = $SaveDialog
@onready var entry_popup: PopupPanel = $EntryPopup
@onready var title_line_edit: LineEdit = $EntryPopup/PopupHBox/FormContainer/TitleLineEdit
@onready var author_line_edit: LineEdit = $EntryPopup/PopupHBox/FormContainer/AuthorLineEdit
@onready var content_text_edit: TextEdit = $EntryPopup/PopupHBox/FormContainer/ContentTextEdit
@onready var save_entry_button: Button = $EntryPopup/PopupHBox/FormContainer/SaveEntryButton
@onready var preview_container: VBoxContainer = $EntryPopup/PopupHBox/PreviewContainer

var new_entry_path: String = ""
var preview_instance: Node = null
var log_entry_scene: PackedScene = load("res://nodes/objects/instancing/logPreview.tscn")

func _ready():
	new_entry_button.connect("pressed", Callable(self, "_on_new_entry_pressed"))
	delete_button.connect("pressed", Callable(self, "_on_delete_pressed"))
	entry_tree.connect("item_selected", Callable(self, "_on_item_selected"))
	entry_tree.connect("item_activated", Callable(self, "_on_item_activated"))
	save_dialog.connect("file_selected", Callable(self, "_on_file_selected"))
	save_entry_button.connect("pressed", Callable(self, "_on_save_entry_pressed"))
	title_line_edit.connect("text_changed", Callable(self, "update_entry_preview"))
	author_line_edit.connect("text_changed", Callable(self, "update_entry_preview"))
	content_text_edit.connect("text_changed", Callable(self, "update_entry_preview"))
	preview_instance = log_entry_scene.instantiate()
	preview_container.add_child(preview_instance)
	refresh_tree()

func _on_new_entry_pressed():
	save_dialog.current_path = "res://!devlog!/new entry.json"
	save_dialog.popup_centered_ratio(0.6)

func _on_file_selected(path: String):
	new_entry_path = path
	title_line_edit.text = ""
	author_line_edit.text = ""
	content_text_edit.text = ""
	update_entry_preview()
	entry_popup.popup_centered_ratio(0.8)

func _on_save_entry_pressed():
	var title = title_line_edit.text
	var author = author_line_edit.text
	var date = _get_current_datetime()
	var content = [ content_text_edit.text ]

	var data = {
		"title": title,
		"author": author,
		"date": date,
		"content": content,
		"images": [ "" ]
	}

	var file_name_base = ut.camelCase(title.strip_edges().to_lower())
	var timestamp = date.replace("-", "").replace(":", "").replace(" ", "_")
	var file_name = file_name_base + "_" + timestamp + ".json"
	new_entry_path = "res://!devlog!/" + file_name

	var json_str = JSON.stringify(data, "\t")

	var f = FileAccess.open(new_entry_path, FileAccess.WRITE)
	if f:
		f.store_string(json_str)
		f.close()
	else:
		push_error("Failed to open file for writing at: " + new_entry_path)

	entry_popup.hide()
	refresh_tree()
	EditorInterface.get_resource_filesystem().scan()

func _on_item_selected():
	var item = entry_tree.get_selected()
	if item:
		var file_path = item.get_metadata(0)
		var file_text = file.open(file_path)
		var data = file.parse(file_text)
		if data:
			var author = data.get("author", "Unknown Author")
			var date   = data.get("date", "No Date")
			var content_array = data.get("content", [])
			var content_text = ""
			if content_array is Array:
				content_text = "\n".join(content_array)
			else:
				content_text = str(content_array)
			var preview = "Author: " + str(author) + "\n"
			preview += "Date: " + str(date) + "\n\n"
			preview += "Content:\n" + content_text
			content_preview.text = preview
		else:
			content_preview.text = "Error: Could not parse JSON from: " + file_path

func _on_item_activated():
	var item = entry_tree.get_selected()
	if item:
		var file_path = item.get_metadata(0)
		var file_text = file.open(file_path)
		var data = file.parse(file_text)
		if data:
			title_line_edit.text = data.get("title", "")
			author_line_edit.text = data.get("author", "")
			var content_array = data.get("content", [])
			if content_array is Array:
				content_text_edit.text = "\n".join(content_array)
			else:
				content_text_edit.text = str(content_array)
			new_entry_path = file_path
			update_entry_preview()
			entry_popup.popup_centered()
		else:
			push_error("Error: Could not parse JSON from " + file_path)

func _on_delete_pressed():
	var item = entry_tree.get_selected()
	if item:
		var file_path = item.get_metadata(0)
		var d = DirAccess.open("res://")
		if d:
			var err = d.remove(file_path)
			if err != OK:
				push_error("Failed to delete file: " + file_path)
			else:
				print(file_path, " deleted.")
				refresh_tree()
				EditorInterface.get_resource_filesystem().scan()

func refresh_tree():
	entry_tree.clear()
	var root_item = entry_tree.create_item()
	var file_list = file.openDir("res://!devlog!")
	for file_path in file_list:
		var file_text = file.open(file_path)
		var data = file.parse(file_text)
		var item = entry_tree.create_item(root_item)
		if data and data.has("title") and data["title"] != "":
			var clean_title = remove_bbcode(data["title"])
			item.set_text(0, clean_title)
		else:
			item.set_text(0, file_path.get_file())
		item.set_metadata(0, file_path)

func _get_current_datetime() -> String:
	var dt = Time.get_datetime_dict_from_system()
	var formatted = "%04d-%02d-%02d %02d:%02d:%02d" % [ dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second ]
	return formatted

func remove_bbcode(text: String) -> String:
	var regex := RegEx.new()
	var error = regex.compile("\\[/?[^\\]]+\\]")
	if error != OK:
		push_error("RegEx compile error: " + str(error))
		return text
	return regex.sub(text, "", true)

func update_entry_preview():
	var data = {
		"title": title_line_edit.text,
		"author": author_line_edit.text,
		"date": _get_current_datetime(),
		"content": [ content_text_edit.text ]
	}
	if preview_instance and preview_instance.has_method("update_preview"):
		preview_instance.update_preview(data)
	else:
		if preview_instance:
			var sub_viewport = preview_instance.get_node_or_null("SubViewport")
			if sub_viewport == null:
				push_error("SubViewport not found in preview_instance. Available children: " + str(preview_instance.get_children()))
				return
			var control_node = sub_viewport.get_node_or_null("Control")
			if control_node == null:
				push_error("Control node not found under SubViewport. Available children of SubViewport: " + str(sub_viewport.get_children()))
			var title_label = control_node.get_node_or_null("Title") if control_node != null else null
			var date_label = sub_viewport.get_node_or_null("Date")
			var author_label = sub_viewport.get_node_or_null("Author")
			var content_label = sub_viewport.get_node_or_null("Content")
			if title_label:
				title_label.bbcode_text = "[b]" + title_line_edit.text + "[/b]"
			else:
				push_error("Title label not found at path 'SubViewport/Control/Title'.")
			if date_label:
				date_label.bbcode_text = "[i]" + _get_current_datetime() + "[/i]"
			else:
				push_error("Date label not found at path 'SubViewport/Date'.")
			if author_label:
				author_label.bbcode_text = author_line_edit.text
			else:
				push_error("Author label not found at path 'SubViewport/Author'.")
			if content_label:
				content_label.bbcode_text = content_text_edit.text
			else:
				push_error("Content label not found at path 'SubViewport/Content'.")
		else:
			push_error("Preview instance is not available.")
