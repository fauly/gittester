@tool
extends Node3D

signal file_path_assigned(file_path)

var _file_path: String = ""

@export var file_path: String:
	set(value):
		_file_path = value
		emit_signal("file_path_assigned", value)
		populate_with_file()
	get:
		return _file_path

func populate_with_file() -> bool:
	var content := file.open(file_path)  # returns the file's text contents
	var data: Variant= file.parse(content)      # now parse the actual JSON string

	if data == null:
		return false
	
	$SubViewport/Title.clear()
	$SubViewport/Title.append_text("[b][font_size=36]"+data.title+"[/font_size][/b]")
	
	$SubViewport/Author.clear()
	$SubViewport/Author.append_text("[i][font_size=24]"+data.author+"[/font_size][/i]")
	
	$SubViewport/Date.clear()
	var date = data.date.split(" ")
	date = date[0] + "\n" + date[1]
	$SubViewport/Date.append_text("[font_size=18]"+date+"[/font_size]")
	
	
	$SubViewport/Content.clear()
	$SubViewport/Content.append_text(data.content)
	#print("Populating from file:", file_path)

	return true
