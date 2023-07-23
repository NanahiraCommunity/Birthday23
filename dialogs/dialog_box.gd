extends Control

var dialogue: DialogueResource # loaded resource to the .dialogue file
var next_dialogue: String      # id/title of dialog set being displayed
var current_line: DialogueLine # currently displayed line

# for options dialog
var choosing = false
var rendering = false
var selected_index = 0
var option_nodes = []

func _ready():
	pass

func _process(delta):
	if not visible:
		Global.in_dialog = false
		return
	Global.in_dialog = true
	
	$NextIndicator.visible = not rendering and not choosing and next_dialogue != null
	$Cursor.visible = choosing
	if choosing:
		$Cursor.global_position.y = option_nodes[selected_index].global_position.y

	$NinePatchRect.size = $MarginContainer.size
	$NinePatchRect.position = $MarginContainer.position

func _input(event: InputEvent) -> void:
	if not visible:
		return
	
	var handled = false
	if choosing:
		if event.is_action_pressed("ui_up") or event.is_action_pressed("walk_up"):
			selected_index -= 1
			if selected_index < 0:
				selected_index = len(option_nodes) - 1
			handled = true
		if event.is_action_pressed("ui_down") or event.is_action_pressed("walk_down"):
			selected_index += 1
			if selected_index >= len(option_nodes):
				selected_index = 0
			handled = true
		if event.is_action_pressed("ui_accept"):
			next_dialogue = current_line.responses[selected_index].next_id
			show_next()
			handled = true
	else:
		if event.is_action_pressed("ui_accept"):
			if rendering:
				# copied from their skip code
				# Run any inline mutations that haven't been run yet
				for i in range($MarginContainer/VBoxContainer/Text.visible_characters, $MarginContainer/VBoxContainer/Text.get_total_character_count()):
					$MarginContainer/VBoxContainer/Text.mutate_inline_mutations(i)
				$MarginContainer/VBoxContainer/Text.visible_characters = $MarginContainer/VBoxContainer/Text.get_total_character_count()
				$MarginContainer/VBoxContainer/Text.is_typing = false
				$MarginContainer/VBoxContainer/Text.finished_typing.emit()
			else:
				show_next()
			handled = true

	if handled:
		get_viewport().set_input_as_handled()

func trigger_dialog(path, _next_dialogue: String):
	# Display the dialog UI
	choosing = false

	dialogue = load(path)
	next_dialogue = _next_dialogue
	
	set_visible(true)
	show_next()


func show_next():
	if rendering:
		return

	rendering = true
	
	current_line = await dialogue.get_next_dialogue_line(next_dialogue) if dialogue else null

	if not current_line:
		# No dialog left
		set_visible(false)
		rendering = false
		return

	for child in option_nodes:
		$MarginContainer/VBoxContainer.remove_child(child)
	option_nodes = []

	next_dialogue = current_line.next_id
	choosing = false

	$MarginContainer/VBoxContainer/Name.text = current_line.character
	$MarginContainer/VBoxContainer/Text.dialogue_line = current_line
	$MarginContainer/VBoxContainer/Text.type_out()

	await $MarginContainer/VBoxContainer/Text.finished_typing
	
	if current_line.responses:
		choosing = true
		for response in current_line.responses:
			var option: RichTextLabel = $MarginContainer/VBoxContainer/OptionTemplate.duplicate()
			if not response.is_allowed:
				option.text = "[color=#00000060]" + response.text + "[/color]"
			else:
				option.text = response.text
			option.visible = true
			$MarginContainer/VBoxContainer.add_child(option)
			option_nodes.push_back(option)
		selected_index = 0
	rendering = false
