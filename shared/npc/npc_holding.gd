extends "res://shared/npc/npc_character.gd"

var hand_bone: int

@export var debug_adjust: bool = false
@export var item_offset: Vector3 = Vector3.ZERO
@export var item_rotation: Vector3 = Vector3.ZERO
@export var animation: String = "HoldR"
@export var lock_bone: String = "HandR"

@onready var item_transform = Transform3D(Basis.from_euler(item_rotation * PI / 180.0), item_offset)

func _ready():
	super()
	controller.set_arms(animation)
	hand_bone = skeleton.find_bone(lock_bone)

func _input(event):
	if debug_adjust:
		var handled = false
		if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var d = -0.001 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.001
			if Input.is_key_pressed(KEY_1):
				item_offset.x += d
				handled = true
			if Input.is_key_pressed(KEY_2):
				item_offset.y += d
				handled = true
			if Input.is_key_pressed(KEY_3):
				item_offset.z += d
				handled = true
			if Input.is_key_pressed(KEY_4):
				item_rotation.x += d * 100
				handled = true
			if Input.is_key_pressed(KEY_5):
				item_rotation.y += d * 100
				handled = true
			if Input.is_key_pressed(KEY_6):
				item_rotation.z += d * 100
				handled = true
		elif event is InputEventMouseButton:
			if Input.is_key_pressed(KEY_1):
				item_offset.x = 0
				handled = true
			if Input.is_key_pressed(KEY_2):
				item_offset.y = 0
				handled = true
			if Input.is_key_pressed(KEY_3):
				item_offset.z = 0
				handled = true
			if Input.is_key_pressed(KEY_4):
				item_rotation.x = 0
				handled = true
			if Input.is_key_pressed(KEY_5):
				item_rotation.y = 0
				handled = true
			if Input.is_key_pressed(KEY_6):
				item_rotation.z = 0
				handled = true
		if handled:
			item_transform = Transform3D(Basis.from_euler(item_rotation * PI / 180.0), item_offset)
			print("OFFSET: ", item_offset, " - ROTATION: ", item_rotation);
			get_viewport().set_input_as_handled()
			return
	super(event)

func _process(delta):
	super(delta)
	var pose = skeleton.get_bone_global_pose(hand_bone)
	$Item.global_transform = skeleton.global_transform * pose * item_transform
