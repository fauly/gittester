@tool
extends EditorScript

func _run():
	print("🔍 Scanning for duplicate class_names...")
	var dir = DirAccess.open("res://")
	dir.set_include_hidden(true)
	dir.set_include_navigational(true)
	dir.list_dir_begin()
	var seen = {}
	var file = dir.get_next()
	while file != "":
		if file.ends_with(".gd"):
			var path = "res://" + file
			var text = FileAccess.open(path, FileAccess.READ).get_as_text()
			print("Current file: ",path)
			for line in text.split("\n"):
				if line.strip_edges().begins_with("class_name"):
					var name = line.strip_edges().split(" ")[1]
					if name in seen:
						print("❌ Duplicate class_name '%s'" % name)
						print("   ↳ %s" % seen[name])
						print("   ↳ %s" % path)
					else:
						seen[name] = path
		file = dir.get_next()
