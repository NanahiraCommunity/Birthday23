extends ColorRect
signal scene_changed(scene_name)

@onready var animator = $AnimationPlayer

#var _start_scene: String

var next_scene_path
var player_pos
var left_door_animation
var right_door_animation 
var next_scene

const HEAD_OFFSET = Vector3(0, 0.15, 0)

func _ready():
	visible = false


func _on_scene_changed(scene_path):
	var scene_name = scene_path.get_file().get_basename()
	print("Scene name :", scene_name)

#func fade_to_black():
	#var camera = get_viewport().get_camera_3d()
	#player_pos = camera.unproject_position(camera.target.global_position + HEAD_OFFSET)
	#material.set_shader_parameter("center", player_pos)
	#animator.play("Out")
	#visible = true
	#await animator.animation_finished

#func unfade_from_black(delay: float = 0.0):
	#if delay > 0.0:
	#	await get_tree().create_timer(delay).timeout
	#var camera = get_viewport().get_camera_3d()
	#player_pos = camera.unproject_position(camera.target.global_position + HEAD_OFFSET)
	#material.set_shader_parameter("center", player_pos)
	#animator.play("In")
	#await animator.animation_finished
	#visible = false

func switch_scene(scene_path):
	next_scene_path = scene_path
	print("Switching to scene: ", next_scene_path)
	#await fade_to_black()
	#var bgm = Global.UI.get_node_or_null("BGM")
	#if bgm:
	#	bgm.reparent(self)
	#else:
	#	bgm = get_node("BGM")
	var next: PackedScene = load(next_scene_path)
	get_tree().change_scene_to_packed(next)
	var scene_name = next_scene_path.get_file().get_basename()
	_on_scene_changed(scene_name)
	emit_signal("scene_changed", scene_name)
	await get_tree().process_frame # scene is adding now
	#var new_bgm = get_tree().current_scene.get_node_or_null("BGM")
	#if new_bgm and new_bgm.stream:
		#new_bgm.stop()
		#if new_bgm.stream != bgm.stream:
			#bgm.stream = new_bgm.stream
			#bgm.play()
	#else:
		#bgm.stop()

	await get_tree().process_frame # first frame was rendered
	#await unfade_from_black()
# Additional functions for main_menu
func switch_to_start_scene():
	switch_scene("res://islands/hub/hub_world.tscn")

func switch_to_options_scene():
	switch_scene("res://ui/options_menu.tscn")


