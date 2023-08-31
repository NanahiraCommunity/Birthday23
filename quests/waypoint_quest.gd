class_name WaypointQuest
extends Quest

@export var show_marker: bool = true

var current = 0
var max = 0
var markers: Array[Node3D] = []
var marker: Node3D

func start():
	super()
	var children = get_children()

	if show_marker:
		marker = preload("res://quests/waypoint_3d.tscn").instantiate()
		add_child(marker)
	else:
		marker = null

	markers = []
	current = -1
	for child in children:
		if child is Node3D:
			# can be CollisionShape3D or anything really that will get reparented to Area3D
			# can group multiple CollisionShape3D by making them children of a Node3D
			var area = Area3D.new()
			add_child(area)
			child.reparent(area)
			markers.append(child)
			current += 1
			area.body_entered.connect(_body_entered.bind(current))
	assert(current >= 0, "Missing children (CollisionShape3D) in waypoint quest")
	current = -1
	max = markers.size() - 1

func _finished():
	super()
	_ended()

func _ended():
	if marker:
		marker.queue_free()
		marker = null

func _process(delta):
	if not done and marker:
		var next = current + 1
		if next < markers.size():
			marker.global_position = markers[next].global_position

func _body_entered(body: Node, i: int):
	if done:
		return
	if body == Global.player:
		current = max(current, i)
		if i >= max:
			_finished()
