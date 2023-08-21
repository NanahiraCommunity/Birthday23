extends GridMap

func _ready():
	var stamp = preload("res://shared/collectible/confetto_stamp.tscn")
	var p = get_parent()
	var scene = get_tree().current_scene.scene_file_path
	var grid_name = scene + ">" + String(get_path())
	if not grid_name in Global.collected_grids:
		Global.collected_grids[grid_name] = {}
	var map = Global.collected_grids[grid_name]

	for pos in get_used_cells():
		if pos in map:
			continue
		var s = stamp.instantiate()
		s.grid_pos = pos
		s.grid_name = grid_name
		var value = get_value(get_cell_item(pos))
		s.value = value
		s.basis = basis
		s.scale = scale
		s.position = position + map_to_local(pos)
		p.add_child.call_deferred(s)
	queue_free()

func get_value(index: int):
	if index == 0:
		return 1
	elif index == 1:
		return 10
	else:
		assert(false)
