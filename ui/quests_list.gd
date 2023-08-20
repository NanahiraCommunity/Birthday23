extends Control

# map of current root quest IDs -> UI elements
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
		new_quests.append(quest)

	await add_quests(new_quests)

	for quest in Global.active_quests:
		var i = missing.find(quest.quest_id)
		if i != -1:
			missing.remove_at(i)

	var to_remove: Array[Node] = []
	for m in missing:
		to_remove.append(current_quests[m])
		current_quests.erase(m)

	if to_remove:
		await hide_quests(to_remove)

func hide_quests(nodes: Array[Node]):
	for node in nodes:
		node.hide_animated_and_free()

func add_quests(quests: Array[Quest]):
	var quest_line = preload("res://quests/quest_line.tscn")
	var quest_subline = preload("res://quests/quest_subline.tscn")
	for quest in quests:
		if current_quests.has(quest.quest_id):
			continue

		var node = quest_line.instantiate()
		status_updater(quest, node, null)
		node.show_animated()
		$VBoxContainer.add_child(node)
		current_quests[quest.quest_id] = node

		for child in quest.get_children():
			if child is Quest:
				var subnode = quest_subline.instantiate()
				status_updater(child, subnode, node)
				subnode.show_animated()
				$VBoxContainer.add_child(subnode)
				# don't add to current_quests, since this is a sub-quest

func status_updater(quest: Quest, node: Node, child_of: Node):
	while not quest.done:
		node.text = Global.preprocess_bbcode(quest.get_text())
		await quest.updated
	node.text = Global.preprocess_bbcode(quest.get_text())
	node.mark_finished()
	if child_of:
		await node.hide_animated_and_free(3.0)
