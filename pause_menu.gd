extends ColorRect

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ResumeButton
@onready var quit_button: Button = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/QuitButton

var _mainmenu_scene: String
@export_file("*.tscn") var mainmenu_scene: String:
	get:
		return _mainmenu_scene
	set(value):
		_mainmenu_scene = value

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		unpause() if is_visible() else pause()

func _ready():
	resume_button.pressed.connect(unpause)
	quit_button.pressed.connect(get_tree().quit)

# Option for title screen. Bug where going to title screen causes
# no buttons to be pressed
func mainmenu():
	get_tree().change_scene_to_file(_mainmenu_scene)

func unpause():
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func pause():
	visible = true
	get_tree().paused = true
	animator.play("Pause")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
