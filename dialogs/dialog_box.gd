extends Control

var file_path = "res://dialogs/dialog_data.json"
var dialog_data = get_dialog_data()		# dictionary consisting all the dialog in the game
var dialog = []		# list of dialog currently being displayed
var character		# id of character currently speaking
var dialog_id		# id of dialog set being displayed

@export var text_speed = 0.05	# seconds per character
var dialog_index = 0
var finished = false

# for options dialog
var choosing = false
var options	= []
var selected_index = 0

func _ready():
	$Timer.wait_time = text_speed

func _process(delta):
	if not visible: return
	
	$NextIndicator.visible = finished
	$Cursor.visible = choosing
	
	# When spacebar/enter is pressed
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			# If dialog text finished animating, check if the dialog has options
			if "options" in dialog[dialog_index]:
				trigger_option_dialog()
			else:
				# Otherwise, go to next dialog
				dialog_index += 1
				next_dialog()
		elif choosing:
			# If options dialog is open, jump to selected option
			trigger_dialog(character, options[selected_index]["jump_to"])
		else:
			# Skip animation and display entire text
			$Text.visible_characters = len($Text.text)
	
	if choosing:
		if Input.is_action_just_pressed("ui_up"):
			select_option( (selected_index + len(options) - 1) % len(options) )
		if Input.is_action_just_pressed("ui_down"):
			select_option( (selected_index + 1) % len(options) )


func get_dialog_data() -> Dictionary:
	# Store JSON contents to dialog_data
	assert(FileAccess.file_exists(file_path), "File path does not exist")
	
	var data_file = FileAccess.open(file_path, FileAccess.READ)
	var parsed_result = JSON.parse_string(data_file.get_as_text())
	
	assert(parsed_result is Dictionary, "Error reading file")
	return parsed_result
	

func trigger_dialog(_character, _dialog_id):
	# Display the dialog UI
	finished = false
	choosing = false
	
	character = _character
	dialog_id = _dialog_id
	dialog = dialog_data[character][dialog_id]
	dialog_index = 0
	
	set_visible(true)
	next_dialog()


func next_dialog():
	if dialog_index >= len(dialog):
		# No dialog left
		set_visible(false)
		return
	
	finished = false
	
	$Name.bbcode_text = dialog[dialog_index]["name"]
	$Text.bbcode_text = dialog[dialog_index]["text"]
	$Text.visible_characters = 0
	
	# Text animation, display text character by character
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		$Timer.start()
		await $Timer.timeout
	
	finished = true
	
func trigger_option_dialog():
	finished = false
	choosing = true
	
	options = dialog[dialog_index]["options"]
	var options_text = []
	for opt in options: options_text.append(opt["text"])
		
	$Name.bbcode_text = " "
	$Text.bbcode_text = "\n".join(options_text)
	
	select_option(0)


func select_option(index):
	selected_index = index
	$Cursor.position.y = $Text.position.y + $Text.get_theme_font_size("normal_font_size") * 1.4 * index
