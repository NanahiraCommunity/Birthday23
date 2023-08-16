extends Node3D

@export var padding: float = 32.0

func _process(delta):
	var camera = get_viewport().get_camera_3d()
	if camera:
		var p3d = global_position
		var p = camera.unproject_position(p3d)
		var window = get_viewport().get_window().size
		if camera.is_position_behind(p3d):
			var half = Vector2(window.x / 2.0, window.y / 2.0)
			p -= half
			p = -p
			p /= Vector2(p.x / half.x, p.y / half.y).length() * 0.5
			p += half
		p = p.clamp(Vector2(padding, padding), Vector2(window.x - padding, window.y - padding))
		$Sprite2D.position = p
