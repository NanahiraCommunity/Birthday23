extends "res://shared/npc/npc_character.gd"

@export var carry_area: Area3D
@export var safe_area: Area3D

var time: float = 0.0
var defend: bool = false
var carry: bool = false
var self_no: int = 0
var carry_go: bool = false

static var carry_done = false
static var carry_drop_off: Node3D = null
static var instance_no = 0

func _ready():
	dynamic_collision = true
	super()
	time = instance_no * TAU / 4
	self_no = instance_no
	instance_no += 1
	var shape: CapsuleShape3D = $DynamicCollision.shape.duplicate()
	shape.radius /= 1.5
	shape.height /= 1.5
	$DynamicCollision.shape = shape
	controller.set_movement_animation("Minihira-float", true)
	$DefendArea.body_entered.connect(_body_entered)
	$DefendArea.body_exited.connect(_body_exited)
	carry_area.body_entered.connect(_carry_entered)
	safe_area.body_exited.connect(_carry_exited)

func _physics_process(delta):
	var target: Vector3
	var exp: float
	var ldefend: bool
	var tp_player: bool
	if carry_done:
		carry = false

	if carry:
		collision_layer = 0
		collision_mask = 0
		var gtransform = global_transform
		var current = $NanahiraPapercraft.global_position
		var player = Global.player.global_position
		target = player + carry_offset
		if target.distance_squared_to(current) < 0.07 * 0.07 or (carry_drop_off and carry_drop_off.carry_go):
			if not carry_drop_off:
				carry_drop_off = self
			target = carry_drop_off.drop_off_point.global_position + carry_offset
			exp = 0.3
			delayed_go()
			if not carry_drop_off.carry_go:
				exp = 1.0
			if carry_drop_off == self:
				tp_player = true
			if target.distance_squared_to(current) < 0.2 * 0.2:
				carry_done = true
				carry_drop_off = null
		else:
			exp = 0.01
			if carry_drop_off == self:
				tp_player = true

		$NanahiraPapercraft.global_position = ($NanahiraPapercraft.global_position - target) * pow(exp, delta) + target;
		local_position = local_position # assign others
	else:
		collision_layer = 1
		collision_mask = 1
		time += delta
		ldefend = defend and not Global.player.on_floor
		target = calc_fly_pos(ldefend)
		exp = 0.005 if ldefend else 0.3

		local_position = (local_position - target) * pow(exp, delta) + target;
		if ldefend and target.distance_squared_to(local_position) < 0.07 * 0.07:
			local_position = target

	if tp_player:
		Global.player.global_position = $NanahiraPapercraft.global_position - carry_offset

var carry_offset: Vector3:
	get:
		var dist = 0.1
		var x = -1 if (self_no == 0 || self_no == 2) else 1
		var y = -1 if (self_no == 1 || self_no == 2) else 1
		return Vector3(x * dist, -0.3, y * dist)

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

func _carry_entered(body):
	if body == Global.player and not carry:
		carry_done = false
		carry = true
		carry_go = false
		print("carry operation!!")

func _carry_exited(body):
	if body == Global.player:
		carry_done = true
		carry_drop_off = null

func delayed_go():
	await get_tree().create_timer(0.8).timeout
	carry_go = true

var drop_off_point:
	get:
		return $DropOff
