extends CharacterBody3D

enum Type
{
	MIXED,
	TWO_SIZE,
	SORTED_PACKAGES,
	SORTED_LETTERS,
}

@export var type: Type = Type.MIXED
@export var emptying = false
@export var functional = true

const SPEED = 10.0

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 0.2

var items = 0
var desk = null

var target = Vector3.INF
var target_time = 0.0

var reset_collision_layer: int

var items_node: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if functional:
		self.add_to_group("carts")
	reset_collision_layer = collision_layer
	items_node = Node3D.new()
	add_child(items_node)

func set_pushing(pushing: bool):
	if pushing:
		self.collision_layer = 0
		$NavigationObstacle3D.avoidance_enabled = false
	else:
		self.collision_layer = reset_collision_layer
		$NavigationObstacle3D.avoidance_enabled = true

func transition_to(location: Vector3):
	target = location
	target_time = 4.0

func _physics_process(delta):
	if not functional:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if target != Vector3.INF and target_time > 0:
		global_position.x += (target.x - global_position.x) * min(1.0, delta * SPEED)
		global_position.z += (target.z - global_position.z) * min(1.0, delta * SPEED)
		target_time -= delta

	move_and_slide()

func align_to_desk():
	if desk:
		var p = desk.get_node("CartArea").global_position
		global_position.x = p.x
		global_position.z = p.z
		global_rotation = desk.get_node("CartArea").global_rotation
		if emptying:
			rotate_y(PI)
		target_time = 0
		velocity = Vector3.ZERO

func get_areas():
	match type:
		Type.MIXED:
			return [
				$Areas/Mixed
			]
		Type.TWO_SIZE:
			return [
				$Areas/Letters,
				$Areas/Packages
			]
		Type.SORTED_PACKAGES:
			return [
				$Areas/Packages1,
				$Areas/Packages2,
				$Areas/Packages3,
				$Areas/Packages4,
				$Areas/Packages5,
				$Areas/Packages6,
			]
		Type.SORTED_LETTERS:
			return [
				$Areas/Letters1,
				$Areas/Letters2,
				$Areas/Letters3,
				$Areas/Letters4,
				$Areas/Letters5,
				$Areas/Letters6,
				$Areas/Letters7,
				$Areas/Letters8,
				$Areas/Letters9,
				$Areas/Letters10,
				$Areas/Letters11,
				$Areas/Letters12,
			]

func get_target_area(letter: bool):
	match type:
		Type.MIXED:
			return $Areas/Mixed
		Type.TWO_SIZE:
			return $Areas/Letters if letter else $Areas/Packages
		Type.SORTED_PACKAGES:
			return null if letter else get_areas()[randi_range(0, 5)]
		Type.SORTED_LETTERS:
			return null if not letter else get_areas()[randi_range(0, 11)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
