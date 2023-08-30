extends Control

@onready var back_btn: Button = $MarginContainer2/VBoxContainer/MarginContainer/VBoxContainer/BackButton
@onready var fullscreen_btn: CheckBox = $MarginContainer2/VBoxContainer/GridContainer/Video/GridContainer/Fullscreen2
@onready var borderless_btn: CheckBox = $MarginContainer2/VBoxContainer/GridContainer/Video/GridContainer/Borderless2
@onready var vsync_btn: CheckBox = $MarginContainer2/VBoxContainer/GridContainer/Video/GridContainer/VSync2

@onready var master_slider: HSlider = $MarginContainer2/VBoxContainer/GridContainer/Audio/GridContainer/Master2
@onready var bgm_slider: HSlider = $MarginContainer2/VBoxContainer/GridContainer/Audio/GridContainer/BGM2
@onready var sfx_slider: HSlider = $MarginContainer2/VBoxContainer/GridContainer/Audio/GridContainer/SFX2

@onready var english_btn: CheckButton = $MarginContainer2/VBoxContainer/GridContainer/Language/GridContainer/English2
@onready var japanese_btn: CheckButton = $MarginContainer2/VBoxContainer/GridContainer/Language/GridContainer/Japanese2

# Called when the node enters the scene tree for the first time.
func _ready():
	back_btn.pressed.connect(_back)
	fullscreen_btn.toggled.connect(_fullscreen)
	borderless_btn.toggled.connect(_borderless)
	vsync_btn.toggled.connect(_v_sync)
	master_slider.value_changed.connect(_master_value_changed)
	bgm_slider.value_changed.connect(_bgm_value_changed)
	sfx_slider.value_changed.connect(_sfx_value_changed)
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))

	var locale = TranslationServer.get_locale()
	if locale.begins_with("ja"):
		japanese_btn.set_pressed_no_signal(true)
	else:
		english_btn.set_pressed_no_signal(true)

	japanese_btn.pressed.connect(_change_locale.bind("ja"))
	english_btn.pressed.connect(_change_locale.bind("en"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Hardcoded because thinking of having the options menu accessable from
# gameplay and when clicking back it will take you there and not to title
func _back():
	visible = false
#	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func _fullscreen(button_pressed):
	print("fullscreen")
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _borderless(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _v_sync(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _master_value_changed(value):
	volume(0, value)

func _bgm_value_changed(value):
	volume(1, value)

func _sfx_value_changed(value):
	volume(2, value)

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _change_locale(locale: String):
	TranslationServer.set_locale(locale)
