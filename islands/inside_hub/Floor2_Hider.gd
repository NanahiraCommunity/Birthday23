extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$Area3D.body_entered.connect(_player_entered)
	$Area3D.body_exited.connect(_player_exited)

func _player_entered(body: Node3D):
	if body == Global.player:
		visible = true

func _player_exited(body: Node3D):
	if body == Global.player:
		visible = false
