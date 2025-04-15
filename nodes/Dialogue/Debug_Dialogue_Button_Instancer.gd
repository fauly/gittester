extends Button

var DialogueScene = preload("")
var inst = null

var dialogue = {
	"0": {
		"image": "angry.png",
		"text": "* Th-then... m-maybe...\n* If you need help,\n  I could",
		"state": "plain",
		"opt_effect": "wv",
	},
	"1": {
		"image": "chiral_smug.png",
		"text": "hello box 1",
		"options": [
			{"text": "meow", "next": "0"},
			{"text": "meow1", "next": "1"}
		]
	},
	"500": {
			"image": "chiral_smug.png",
			"text": "hello 500",
			"options": [
				{"text": "meow", "next": "0"},
				{"text": "meow1", "next": "1"}
			]
	}
}
var startpos = "0"

func _on_pressed():
	print("BUTTON PRESSED")
	if inst != null:
		inst.queue_free()
	inst = DialogueScene.instantiate()
	inst.conversation_data = dialogue
	inst.conversation_start = startpos
	get_parent().add_child(inst)
