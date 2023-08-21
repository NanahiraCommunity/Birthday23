extends Quest

@export var respawn_pos: Marker3D
@export var respawn_camera: Marker3D

signal pressed(n: int)

func start():
	super()
	$Node3D/FirstTrigger.body_entered.connect(_first_trigger)
	respawn_pos.global_transform = $NewPlayerSpawn.global_transform
	respawn_camera.global_transform = $NewCameraSpawn.global_transform

func _first_trigger(body):
	if body != Global.player:
		return
	$Node3D/FirstTrigger.body_entered.disconnect(_first_trigger)

	var buttons = [$Node3D/Button1, $Node3D/Button2, $Node3D/Button3, $Node3D/Button4]
	for i in range(0, buttons.size()):
		buttons[i].user_pressed.connect(_button_press_callback.bind(i))

	for i in range(0, 12): # just give it to the player after 12 tries
		var pattern = [
			randi_range(0, buttons.size() - 1),
			randi_range(0, buttons.size() - 1),
			randi_range(0, buttons.size() - 1)
		]
		var user_index = 0
		var success = true
		for extra in range(0, 3):
			pattern.append(randi_range(0, buttons.size() - 1))
			user_index = 0
			lock(buttons, true)
			await get_tree().create_timer(0.5).timeout
			for btn in pattern:
				await get_tree().create_timer(0.5).timeout
				await buttons[btn].simulate_press()
			lock(buttons, false)
			
			while user_index < pattern.size():
				var btn = await pressed
				if pattern[user_index] != btn:
					success = false
					break
				user_index += 1

			if not success:
				SFX.play(preload("res://sfx/bonk.wav"))
				await get_tree().create_timer(2.0).timeout
				break

		if success:
			break

	$Node3D/Bars.queue_free()
	finished.emit()
	$Animations.play("hide_buttons")

func lock(buttons, locked: bool):
	for button in buttons:
		button.locked = locked

func _button_press_callback(i: int):
	pressed.emit(i)
