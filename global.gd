extends Node

const Player = preload("res://player.gd")

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
	TAIYAKI,
	BUGS,
	PINEAPPLE,
	DOUGH,
}

var collected_dynamics = {}
var collected_grids = {}

# global state

func _ready():
	assert(collectibles.size() == Collectible.values().size())

func _process(delta):
	pass

func preprocess_bbcode(text: String) -> String:
	return text.replace("[b]", "[color=#aa2a0e]").replace("[/b]", "[/color]").replace("\\n", "\n")

var player: Player
var in_dialog: bool = false
var block_player_ui: int = 0 # the same thing, but not auto-reset when dialogs are closing
var in_ui: bool:
	get:
		assert(block_player_ui >= 0)
		return in_dialog or block_player_ui > 0
var tuto_firstload = 1
var collectibles: PackedInt32Array = [
	0, # STAMP
	0, # TAIYAKI
	0, # BUGS
	0, # PINEAPPLES
	0, # DOUGH
]

func collect_animated(c: Collectible, n: int):
	for i in range(0, n):
		collectibles[c] += 1
		await get_tree().create_timer(0.2).timeout

var _completed_quests: Array[StringName]
# StringName -> Quest
var _available_quests: Dictionary = {}
var active_quests: Array[Quest]
signal active_quests_changed

var neko_hacker_available = true
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

func try_start_quest(qid: StringName):
	for i in range(0, active_quests.size()):
		if active_quests[i].quest_id == qid:
			return
	start_quest(qid)

func start_quest(qid: StringName):
	var quest = _available_quests.get(qid)
	assert(quest, "Quest " + qid + " not found!")
	if quest:
		active_quests.append(quest)
		quest.start()
		print("Starting quest " + qid + ": " + quest.get_text())
		active_quests_changed.emit()

func end_quest(qid: StringName):
	assert(try_end_quest(qid), "Failed ending quest '" + qid + "', it wasn't started!")

func try_end_quest(qid: StringName) -> bool:
	for i in range(0, active_quests.size()):
		if active_quests[i].quest_id == qid:
			print("Ended quest " + qid)
			if active_quests[i].done:
				_completed_quests.append(qid)
			active_quests[i].end()
			active_quests.remove_at(i)
			active_quests_changed.emit()
			return true
	return false

func did_complete_quest(qid: StringName):
	return _completed_quests.find(qid) != -1

func in_quest(qid: StringName):
	for i in range(0, active_quests.size()):
		if active_quests[i].quest_id == qid:
			return true
	return false

func get_quest(qid: StringName):
	for i in range(0, active_quests.size()):
		if active_quests[i].quest_id == qid:
			return active_quests[i]
	return null

func is_quest_complete(qid: StringName):
	var quest = _available_quests.get(qid)
	assert(quest, "Quest " + qid + " not found!")
	if quest:
		return quest.done
	else:
		return false

func respawn_scene():
	if neko_world:
		# better performance
		neko_world.reload()
	else:
		get_tree().reload_current_scene()

# per-island state

var neko_world = null

# camellia world

var boosted = false
var has_pizza = false
var minihira_done = 0
