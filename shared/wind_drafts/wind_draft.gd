extends Node3D

var inside = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.body_entered.connect(_body_entered)
	$Area3D.body_exited.connect(_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if inside and Global.player.state == Global.Player.FLYING:
		var v = Global.player.velocity
		var base_strength = clamp(Vector2(v.x, v.z).length(), 0.01, 2.0)
		var h = clamp(Global.player.global_position.y - global_position.y, 0.0, 6.0) / 6.0
		var strength = clamp(((1.0 - h * h) - v.y * 0.2) * base_strength, 0.5, 2.0)
		print(strength)
		Global.player.velocity.y += 0.03 * strength
		Global.player.flight_strokes = Global.player.flight_strokes_max - 1

func _body_entered(body):
	if body != Global.player:
		return
	inside = true

func _body_exited(body):
	if body != Global.player:
		return
	inside = false
