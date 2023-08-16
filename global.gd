extends Node

# enums

enum CartType
{
	MIXED,
	TWO_SIZE,
	SORTED_PACKAGES,
	SORTED_LETTERS,
}

enum Collectible
{
	# must be strictly incrementing, since you can use Collectible.XYZ as index to `collectibles`
	STAMP,
	TAIYAKI
}

# global state

var player: CharacterBody3D
var in_dialog: bool = false

var collectibles: PackedInt32Array = [
	0, # STAMP
	0, # TAIYAKI
]

var _completed_quests: Array[StringName]
# StringName -> Quest
var _available_quests: Dictionary = {}
var active_quests: Array[Quest]
signal active_quests_changed

var neko_hacker_available = false
var camellia_available = false

# Set when interacting (opening dialog) with an NPC
# Usable for `set current_npc.dialog_entry = ""` to set persistent NPC talking state
var current_npc: Node3D
# Dialog script, if currently in dialog
var dialog: Control
# Current UI, if available
var UI: Control

func register_quest(quest: Quest):
	_available_quests[quest.quest_id] = quest

func unregister_quest(quest: Quest):
	_available_quests.erase(quest.quest_id)

func start_quest(qid: StringName):
	var quest = _available_quests.get(qid)
	assert(quest, "Quest " + qid + " not found!")
	if quest:
		active_quests.append(quest)
		quest.start()
		print("Starting quest " + qid + ": " + quest.description)
		active_quests_changed.emit()

func end_quest(qid: StringName):
	for i in range(0, active_quests.size()):
		if active_quests[i].quest_id == qid:
			print("Ended quest " + qid)
			if active_quests[i].done:
				_completed_quests.append(qid)
			active_quests[i].end()
			active_quests.remove_at(i)
			active_quests_changed.emit()
			return true
	assert(false, "Failed ending quest '" + qid + "', it wasn't started!")
	return false

func did_complete_quest(qid: StringName):
	return _completed_quests.find(qid) != -1

func in_quest(qid: StringName):
	for i in range(0, active_quests.size()):
		if active_quests[i].quest_id == qid:
			return true
	return false

func is_quest_complete(qid: StringName):
	var quest = _available_quests.get(qid)
	assert(quest, "Quest " + qid + " not found!")
	if quest:
		return quest.done
	else:
		return false

# per-island state

var neko_world_reset_count = 0

func _ready():
	assert(collectibles.size() == Collectible.values().size())

func _process(delta):
	pass

func give_kassan_letter():
	neko_world_reset_count += 1
	print("Kassan has been given the letter %s times" % neko_world_reset_count)
	get_tree().reload_current_scene()
