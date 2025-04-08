@tool
extends Node

func camelCase(nameToChange: String) -> String:
	var parts = nameToChange.split(" ", false)
	if parts.size() == 0:
		return nameToChange
	var result = parts[0]
	for i in range(1, parts.size()):
		result += parts[i].capitalize()
	return result
