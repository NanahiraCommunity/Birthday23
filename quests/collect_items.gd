class_name CollectItemsQuest
extends Quest

@export var collect_type: Global.Collectible = Global.Collectible.STAMP
@export var collect_amount: int = 1
@export var ignore_current_global_count: bool = false

var offset_amount: int = 0

func start():
	super()
	if not ignore_current_global_count:
		offset_amount = -Global.collectibles[collect_type]

func _process(delta):
	if not done:
		var count = Global.collectibles[collect_type] + offset_amount
		if count >= collect_amount:
			finished.emit()
