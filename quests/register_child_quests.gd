extends Node

func _ready():
	var loaded_quests = get_node("/root/LoadedQuests")
	for child in get_children():
		if child is Quest:
			for q in loaded_quests.get_children():
				if q.quest_id == child.quest_id:
					print("not re-registering duplicate quest with quest ID ", q.quest_id)
					return

			child.reparent(loaded_quests)
			Global.register_quest(child)
		else:
			assert(false, "Child " + child.name + " is not a quest!")
