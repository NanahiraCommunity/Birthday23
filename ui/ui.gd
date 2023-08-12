extends Control

var DialogBox: Node:
	get:
		return $DialogBox

var PauseMenu: Node:
	get:
		return $PauseMenu

func _ready():
	Global.UI = self

func _enter_tree():
	Global.UI = self
