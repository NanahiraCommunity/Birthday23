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

var quests: Array[Quest]

# Set when interacting (opening dialog) with an NPC
# Usable for `set current_npc.dialog_entry = ""` to set persistent NPC talking state
var current_npc: CharacterBody3D
# Dialog script, if currently in dialog
var dialog: Control

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
