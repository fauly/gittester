extends CanvasLayer
@onready var Portrait
@onready var Text = $Border/TextRegion/RichTextLabel
@onready var Option_box = $Border/Choices
@onready var Border = $Border
@onready var Text_dupe = $Dupe
@onready var Text_cursor = $Soul
@onready var Audio_player = $Textsfx
@onready var Next_indicator
@onready var Text_timer = $Texttimer

signal finished_displaying()
signal options_emable()


var conversation_data = {}
var conversation_start = "0"

var letter_index = 0
var clean_index = 0
var dialogue_index = conversation_data
var cursor_index = 0

var text_without_tags = ""

var punc_time = 0.16
var space_time = 0.04
var letter_time = 0.04

var clean_text = ""
var emotion_points = []
#BOOL
var finished_text = false
var finished_anim = false
var has_option = false
var is_in_choice = false

func _ready():
	_setup(conversation_start)
func _setup(section):
	#trim_text
	init_typewrite()
func wipe():
	print("""DEBUG LIST BEFORE WIPE CALL""",
	"\nchartext: ", Text.text, 
	"\nletterindex: ", letter_index,
	"\ncleanindex: ", clean_index,
	"\ndialogueindex: ", dialogue_index,
	"\ncursorindex: ", cursor_index,
	"\ntext_without_tags: ", text_without_tags,
	"\npunctime: ", punc_time,
	"\nspacetime: ", space_time,
	"\nlettertime: ", letter_time,
	"\ncleantext: ", clean_text,
	"\nemotionpointstext: ", emotion_points,
	"\nfinished_text?: ", finished_text,
	"\nfinishedanim?: ", finished_anim,
	"\nhas option?: ", has_option,
	"\nin is choice?: ", is_in_choice
	)
	Text.visible_characters = 0
	Text.text = ""
	letter_index = 0
	clean_index = 0
	dialogue_index = conversation_data
	cursor_index = 0
	text_without_tags = ""
	clean_text = ""
	emotion_points = []
	finished_text = false
	finished_anim = false
	has_option = false
	is_in_choice = false
	for i in range(Option_box.get_child_count()):
		Option_box.get_child(i).queue_free()
func init_typewrite():
	wipe()
	Text.text = conversation_data[conversation_start].text
	trim()
	typewrite()
	animate()
func typewrite():
	Text.visible_characters += 1
	if Text.visible_characters >= clean_text.length():
		print("done this shit")
		finished_displaying.emit()
		return
	if (emotion_points.size()) > 0:
		for i in emotion_points:
			if letter_index == i[0]:
				print("emotion triggered")	
	match clean_text[letter_index]:
		" ":
			Text_timer.start(space_time)
		".",",":
			Text_timer.start(punc_time)
		_:
			Text_timer.start(letter_time)
			audio()
	print("text_index: ",clean_text[letter_index])
	letter_index+=1
func _on_texttimer_timeout():
	if finished_text != true:
		typewrite()
func animate():
	pass
func trim():
	var tilde_positions = []
	var tilde_index = 0
	var erase_index = 0
	var Text_cpy = Text.text
	var trim_text = Text_cpy
	while tilde_index != Text_cpy.length():
		match Text_cpy[tilde_index]:
			"~":
				tilde_positions.append([tilde_index, Text_cpy[tilde_index+1]])
		tilde_index+=1
	print(tilde_positions)
	for i in tilde_positions:
		trim_text = trim_text.erase((i[0]-erase_index),2)
		emotion_points.append([i[0]-erase_index, i[1]])
		erase_index+=2
	print("trimtext: ",trim_text)
	Text.text = trim_text
	clean_text = Text.get_parsed_text()
func audio():
	var new_Audio_player = Audio_player.duplicate()
	get_tree().root.add_child(new_Audio_player)
	new_Audio_player.play()
	await new_Audio_player.finished
	new_Audio_player.queue_free()
func Option_box_handler():
	var counter = 1
	for option in conversation_data[conversation_start].options:
		var poop = Text_dupe.duplicate()
		poop.text = option.text
		poop.position = Vector2(Option_box.size.x/2,Option_box.size.y/2+(35*counter))
		print(poop.position)
		Option_box.add_child(poop)
		counter+=1
	#set bool for cursor movement true
	is_in_choice = true
	move_cursor_option("n")
func _on_finished_displaying():
	print("baka")
	finished_text = true
	if conversation_data[conversation_start].has("options"):
		Option_box_handler()
func move_cursor_option(imp: String):
	match imp:
		"u":
			cursor_index += -1
		"d":
			cursor_index += 1
		"n":
			cursor_index = 0
	if cursor_index > (Option_box.get_child_count()-1):
		cursor_index = 0
	if cursor_index < 0:
		cursor_index = (Option_box.get_child_count()-1)
	for child_index in range(Option_box.get_child_count()):
			var curitem = Option_box.get_child(child_index)
			if child_index == cursor_index:
				curitem.text = "[w]"+conversation_data[conversation_start].options[cursor_index].text+"[/w]"
			elif child_index != cursor_index:
				curitem.text = conversation_data[conversation_start].options[child_index].text
				#conversation_data[conversation_start].options[child_index].text
func _unhandled_input(event):
	if (
		event.is_action_pressed("advance_dialogue") &&
		finished_text &&
		finished_anim &&
		dialogue_index <= conversation_data.size() &&
		has_option == false
	):
		print("meow")
	
	if (event.is_action_pressed("skip_dialogue") && is_in_choice):
		move_cursor_option("u")
	if (event.is_action_pressed("ui_down") && is_in_choice):
		move_cursor_option("d")
	if (event.is_action_pressed("ui_left") && is_in_choice):
		#save choice
		#move to next option
		conversation_start = conversation_data[conversation_start].options[cursor_index].next
		init_typewrite()
		move_cursor_option("n")
	if (event.is_action_pressed("ui_left") && finished_text && conversation_data[conversation_start].has("options")):
		conversation_start = conversation_data[conversation_start].options[cursor_index].next
		init_typewrite()
	if event.is_action_pressed("ui_up") && !finished_displaying && !is_in_choice:
		Text.visible_characters = -1
