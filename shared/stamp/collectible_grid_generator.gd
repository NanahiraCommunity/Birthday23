extends GridMap

func _ready():
	var stamp = preload("res://shared/stamp/confetto_stamp.tscn")
	var p = get_parent()
	for pos in get_used_cells():
		var s = stamp.instantiate()
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
		return 5
	else:
		assert(false)
