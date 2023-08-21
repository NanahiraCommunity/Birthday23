extends Node3D

var destroying = false

func _ready():
	add_to_group("bugs")
	$Area3D.body_entered.connect(_body_entered)

func _body_entered(body: Node3D):
	if body == Global.player and not destroying:
		destroying = true
		$CSGBox3D.visible = false
		$GPUParticles3D.emitting = false
		$GPUParticles3D2.emitting = false
		$Rot.emitting = false
		$Explode.emitting = true
		SFX.play(preload("res://sfx/bug_squash.wav"))
		Global.collectibles[Global.Collectible.BUGS] += 1
		Global.collect_animated(Global.Collectible.STAMP, 5)
		await get_tree().create_timer(10.0).timeout
		queue_free()
