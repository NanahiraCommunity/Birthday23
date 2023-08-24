extends CSGTorus3D

var collected = false
@export var worth = 5

var mat: Material

func _ready():
	$Area3D.body_entered.connect(_body_entered)
	mat = material.duplicate()
	material = mat

func _body_entered(body):
	if body == Global.player and not collected:
		collected = true
		mat.set_shader_parameter("collected", true)
		for i in range(0, worth):
			SFX.play(preload("res://sfx/pickup_coin.wav"))
			Global.collectibles[Global.Collectible.STAMP] += 1
			await get_tree().create_timer(0.1).timeout
