@tool
extends Node3D

signal file_path_assigned(file_path)

var image_container: Control = null

var _file_path: String = ""

@export var file_path: String:
	set(value):
		_file_path = value
		emit_signal("file_path_assigned", value)
		call_deferred("_deferred_populate_with_file")  # safer!
	get:
		return _file_path

func _deferred_populate_with_file():
	if is_inside_tree():
		populate_with_file()

func populate_with_file() -> bool:
	var content := file.open(file_path)  # returns the file's text contents
	var data: Variant= file.parse(content)      # now parse the actual JSON string

	if data == null:
		return false
	
	$SubViewport/Control/Title.clear()
	$SubViewport/Control/Title.append_text("[b][font_size=36]"+data.title+"[/font_size][/b]")
	
	$SubViewport/Author.clear()
	$SubViewport/Author.append_text("[i][font_size=24]"+data.author+"[/font_size][/i]")
	
	$SubViewport/Date.clear()
	var date = data.date.split(" ")
	date = date[0] + "\n" + date[1]
	$SubViewport/Date.append_text("[font_size=18]"+date+"[/font_size]")
	
	$SubViewport/Content.clear()

# Handle content as either a string or an array
	if typeof(data.content) == TYPE_ARRAY:
		var joined = "\n".join(data.content)
		$SubViewport/Content.append_text(joined)
	else:
		$SubViewport/Content.append_text(data.content)
		
	display_images(data.images)
	#print("Populating from file:", file_path)

	return true
	
# IMG display grid
	

func display_images(image_paths: Array):
	if image_container == null:
		image_container = $SubViewport.get_node_or_null("Images")
	if image_container == null:
		push_warning("Image container missing.")
		return false
	# Clean up existing log entries
	for child in image_container.get_children():
		image_container.remove_child(child)
		child.queue_free()
		
	var max_images = 3
	for i in range(min(image_paths.size(), max_images)):
		var path = image_paths[i]
		var image_node = TextureRect.new()
		image_node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		image_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		image_node.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		image_node.custom_minimum_size = Vector2(0, 150)

		if path.ends_with(".tres"):
			var tex = load(path)
			
			image_node.texture = tex
			#else:
				#print("Failed to load .tres at:", path)
		else:
			var http = HTTPRequest.new()
			add_child(http)  # Important to add to the scene
			http.request_completed.connect(_on_http_done.bind(image_node, http))
			http.request(path)

		image_container.add_child(image_node)

func _on_http_done(result, response_code, headers, body, image_node: TextureRect, http: HTTPRequest):
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		var img = Image.new()
		var err = img.load_png_from_buffer(body)
		if err == OK:
			var tex = ImageTexture.create_from_image(img)
			image_node.texture = tex
		else:
			print("Error loading image from buffer")
	else:
		print("HTTP request failed:", result)
	http.queue_free()
