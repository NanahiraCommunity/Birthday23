@tool
extends MarginContainer

var _text: String
@export var text: String:
	get:
		return _text
	set(value):
		_text = value
		if $HBoxContainer/Label:
			$HBoxContainer/Label.text = value

var _finished: bool
@export var finished: bool:
	get:
		return _finished
	set(value):
		_finished = value
		if $HBoxContainer/Finished:
			$HBoxContainer/Finished.visible = value
			$HBoxContainer/Unfinished.visible = not value

func _ready():
	$HBoxContainer/Label.text = text
	$HBoxContainer/Finished.visible = finished
	$HBoxContainer/Unfinished.visible = not finished

func mark_finished():
	finished = true
