extends Control

@onready var scene_switcher = get_node("/root/SceneSwitcher")
@onready var play_button: Button = $MarginContainer/VBoxContainer/PlayButton
@onready var options_button: Button = $MarginContainer/VBoxContainer/OptionsButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/QuitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	play_button.pressed.connect(start_game)
	options_button.pressed.connect(options_menu)
	quit_button.pressed.connect(get_tree().quit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_game():
	scene_switcher.switch_to_start_scene()

func options_menu():
	scene_switcher.switch_to_options_scene()
