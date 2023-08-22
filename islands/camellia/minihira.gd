extends "res://shared/npc/npc_character.gd"

var time: float = 0.0
var defend

static var instance_no = 0

func _ready():
	dynamic_collision = true
	super()
	time = instance_no * TAU / 4
	instance_no += 1
	var shape: CapsuleShape3D = $DynamicCollision.shape.duplicate()
	shape.radius /= 1.5
	shape.height /= 1.5
	$DynamicCollision.shape = shape
	controller.set_movement_animation("Minihira-float", true)
	$DefendArea.body_entered.connect(_body_entered)
	$DefendArea.body_exited.connect(_body_exited)

func _physics_process(delta):
	time += delta
	var ldefend = defend and not Global.player.on_floor
	var target = calc_fly_pos(ldefend)
	local_position = (local_position - target) * pow(0.005 if ldefend else 0.3, delta) + target;
	if ldefend and target.distance_squared_to(local_position) < 0.07 * 0.07:
		local_position = target

func calc_fly_pos(defend: bool):
	if defend:
		var gtransform = global_transform
		var target = Global.player.global_position - gtransform.origin
		var nrm = gtransform.basis * Vector3(0, 0, 1)
		var dist = target.dot(nrm)
		var ret = gtransform.basis.inverse() * (target - dist * nrm) + Vector3(0, 0, 0.2);
		ret.y = max(0.1, ret.y)
		return ret
	return calc_fly_pos_t(time)

func calc_fly_pos_t(time):
	var t = time * 0.3
	return Vector3(sin(t) * 0.6, cos(t * 1.5) * 0.4 + 0.4, 0.0)

@onready var DynamicCollision_offset = $DynamicCollision.position
@onready var DialogIndicator_offset = $DialogIndicator.position
var local_position:
	get:
		return $NanahiraPapercraft.position
	set(v):
		$NanahiraPapercraft.position = v
		$DynamicCollision.position = v + DynamicCollision_offset
		$DialogIndicator.position = v + DialogIndicator_offset

func _body_entered(body):
	if body != Global.player:
		return
	defend = true
	print("DEFEND!")

func _body_exited(body):
	if body != Global.player:
		return
	defend = false
	var closest_range = INF
	var target = $DynamicCollision.to_local(body.global_position)
	for i in range(0, TAU * 2, 0.1):
		var d = calc_fly_pos_t(i).distance_squared_to(target)
		if d < closest_range:
			closest_range = d
			time = i
	print("relax~")
