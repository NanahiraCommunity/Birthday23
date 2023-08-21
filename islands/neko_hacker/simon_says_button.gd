extends Node3D

signal user_pressed()

var locked: bool
var pressed: bool
var has_player: bool

@export var color_dark: Color
@export var color_pressed: Color
@export var sound: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.body_entered.connect(_body_entered)
	$Area3D.body_exited.connect(_body_exited)
	var m = $CSGCylinder3D.material.duplicate()
	m.set_shader_parameter("albedo", color_dark)
	m.set_shader_parameter("emission", color_pressed)
	$CSGCylinder3D.material_override = m

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$CSGCylinder3D.position.y = -0.04 if pressed else 0.0
	$CSGCylinder3D.material_override.set_shader_parameter("pressed", pressed)

	if has_player and locked:
		timed_release()

func _body_entered(body):
	if body == Global.player and not locked:
		has_player = true
		press_player()

func _body_exited(body):
	if body == Global.player:
		has_player = false
		timed_release()

func simulate_press():
	pressed = true
	SFX.play(sound)
	await get_tree().create_timer(0.3).timeout
	if not has_player:
		pressed = false

func press_player():
	if pressed:
		return
	user_pressed.emit()
	simulate_press()

func timed_release():
	await get_tree().create_timer(0.3).timeout
	if (not locked and has_player) or not pressed:
		return
	pressed = false
