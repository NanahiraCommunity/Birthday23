extends Control

var dialogue: DialogueResource # loaded resource to the .dialogue file
var next_dialogue: String      # id/title of dialog set being displayed
var current_line: DialogueLine # currently displayed line

# for options dialog
var choosing = false
var rendering = false
var selected_index = 0
var option_nodes = []

signal picked_selection(int)

func _ready():
	pass

func _process(delta):
	if not visible:
		Global.in_dialog = false
		Global.dialog = null
		return
	Global.in_dialog = true
	Global.dialog = self

	$NextIndicator.visible = not rendering and not choosing and next_dialogue != null
	$Cursor.visible = choosing
	if choosing:
		$Cursor.global_position.y = option_nodes[selected_index].global_position.y
		for i in range(len(option_nodes)):
			if not current_line.responses[i].is_allowed:
				option_nodes[i].modulate.a = 0.4
			elif i == selected_index:
				option_nodes[i].modulate.a = 1.0
			else:
				option_nodes[i].modulate.a = 0.6

	$NinePatchRect.size = $MarginContainer.size
	$NinePatchRect.position = $MarginContainer.position
	$Name.position.y = $MarginContainer.position.y

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
			if not current_line.responses[selected_index].is_allowed:
				# TODO: play sound
				pass
			else:
				picked_selection.emit(selected_index)
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
		Global.current_npc = null
		rendering = false
		return

	$MarginContainer/VBoxContainer/DialogSeparator.visible = false
	for child in option_nodes:
		$MarginContainer/VBoxContainer.remove_child(child)
		child.queue_free()
	option_nodes = []

	next_dialogue = current_line.next_id
	choosing = false

	title = current_line.character
	$MarginContainer/VBoxContainer/Text.dialogue_line = current_line
	$MarginContainer/VBoxContainer/Text.type_out()

	await $MarginContainer/VBoxContainer/Text.finished_typing

	if current_line.responses:
		choosing = true
		$MarginContainer/VBoxContainer/DialogSeparator.visible = true
		for response in current_line.responses:
			var option: RichTextLabel = $MarginContainer/VBoxContainer/OptionTemplate.duplicate()
			if not response.is_allowed:
				option.text = "[color=#000000]" + response.text + "[/color]"
			else:
				option.text = response.text
			option.visible = true
			$MarginContainer/VBoxContainer.add_child(option)
			option_nodes.push_back(option)
		selected_index = 0
	rendering = false

var title: String:
	get:
		return $Name.text
	set(value):
		$Name.text = value
