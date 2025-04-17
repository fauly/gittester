@tool
extends PanelContainer
class_name ModuleDebugger

var log_box: RichTextLabel

func _ready():
	name = "Module Debugger"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	add_child(vbox)

	var label = Label.new()
	label.text = "⚙️ Module Runtime Monitor"
	vbox.add_child(label)

	log_box = RichTextLabel.new()
	log_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_box.bbcode_enabled = true
	vbox.add_child(log_box)

func update_log(entries: Array):
	log_box.clear()
	for entry in entries:
		var source : String = entry.get("source", "Movement")
		var name : String = entry.get("name", "Unnamed")
		log_box.append_text("[color=gray][b]" + source + "[/b][/color] - [b]" + name + "[/b]\n")
		log_box.append_text("  [i]Before:[/i] " + str(entry.get("before")) + "\n")
		log_box.append_text("  [i]After: [/i] " + str(entry.get("after")) + "\n\n")
