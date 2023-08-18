extends Control

@onready var back_btn: Button = $MarginContainer/VBoxContainer/BackButton
@onready var fullscreen_btn: CheckBox = $Video/HBoxContainer/Checkboxes/Fullscreen
@onready var borderless_btn: CheckBox = $Video/HBoxContainer/Checkboxes/Borderless
@onready var vsync_btn: CheckBox = $Video/HBoxContainer/Checkboxes/VSync

@onready var master_slider: HSlider = $Audio/HBoxContainer/Sliders/Master
@onready var bgm_slider: HSlider = $Audio/HBoxContainer/Sliders/BGM
@onready var sfx_slider: HSlider = $Audio/HBoxContainer/Sliders/SFX

@onready var english_btn: CheckButton = $Language/HBoxContainer/Checkbuttons/English
@onready var japanese_btn: CheckButton = $Language/HBoxContainer/Checkbuttons/Japanese2

# Called when the node enters the scene tree for the first time.
func _ready():
	back_btn.pressed.connect(_back)
	fullscreen_btn.toggled.connect(_fullscreen)
	borderless_btn.toggled.connect(_borderless)
	vsync_btn.toggled.connect(_v_sync)
	master_slider.value_changed.connect(_master_value_changed)
	bgm_slider.value_changed.connect(_bgm_value_changed)
	sfx_slider.value_changed.connect(_sfx_value_changed)
	english_btn.toggled.connect(_en_toggle)
	japanese_btn.toggled.connect(_jp_toggle)
	master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))
	bgm_slider.value = db_to_linear(AudioServer.get_bus_volume_db(1))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(2))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Hardcoded because thinking of having the options menu accessable from
# gameplay and when clicking back it will take you there and not to title
func _back():
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _fullscreen(button_pressed):
	print("fullscreen")
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _borderless(button_pressed):
	if button_pressed == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
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

func _en_toggle():
	japanese_btn.set_pressed_no_signal(false)

func _jp_toggle():
	english_btn.set_pressed_no_signal(false)
