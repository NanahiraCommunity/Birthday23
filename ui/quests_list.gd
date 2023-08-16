extends Control

var current_quests: Dictionary

func _ready():
	update_quests_loop()

func update_quests_loop():
	while true:
		update_quests()
		await Global.active_quests_changed

func update_quests():
	var missing: Array = current_quests.keys()
	var new_quests: Array[Quest] = []

	for quest in Global.active_quests:
		var i = missing.find(quest.quest_id)
		if i != -1:
			missing.remove_at(i)

		new_quests.append(quest)

	await add_quests(new_quests)

	var to_remove: Array[Node] = []
	for m in missing:
		to_remove.append(current_quests[m])
		current_quests.erase(m)

	if to_remove:
		await hide_quests(to_remove)

func hide_quests(nodes: Array[Node]):
	# TODO: animation
	for node in nodes:
		node.queue_free()

func add_quests(quests: Array[Quest]):
	var quest_line = preload("res://quests/quest_line.tscn")
	var quest_subline = preload("res://quests/quest_subline.tscn")
	for quest in quests:
		var node = quest_line.instantiate()
		status_updater(quest, node)
		# TODO: animation
		$VBoxContainer.add_child(node)
		current_quests[quest.quest_id] = node

		for child in quest.get_children():
			if child is Quest:
				var subnode = quest_subline.instantiate()
				status_updater(child, subnode)
				# TODO: animation
				$VBoxContainer.add_child(subnode)
				current_quests[child.quest_id] = subnode

func status_updater(quest: Quest, node: Node):
	while not quest.done:
		node.text = quest.get_text()
		await quest.updated
	node.text = quest.get_text()
	# TODO: animations
	node.mark_finished()
