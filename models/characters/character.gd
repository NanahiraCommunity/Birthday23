extends Node3D

#var animationPlayer: AnimationPlayer

enum Character {
	NANAHIRA,
	MESSENGER,
	NANAHI_2,
	MUCHAHIRA_1,
	MUCHAHIRA_2,
	MUCHAHIRA_3,
	NANAHIRA_PIZZA,
}

const VELOCITY_SCALE = 2.0

var last_velocity = Vector3.ZERO

var _character: Character = Character.NANAHIRA
@export var character: Character:
	get:
		return _character
	set(value):
		_character = value
		update_character()

func _reskin(texture):
	$Armature/Skeleton3D/NanahiraPapercraft.visible = true
	var material: ShaderMaterial = $Armature/Skeleton3D/NanahiraPapercraft.get_surface_override_material(0)
	material = material.duplicate()
	material.set_shader_parameter("texture_paper", texture)
	$Armature/Skeleton3D/NanahiraPapercraft.set_surface_override_material(0, material)

func _ready():
	update_character()

func update_character():
	var scene = null
	var respath = null
	
	$Armature/Skeleton3D/NanahiraPapercraft.visible = false
	
	match(_character):
		Character.NANAHIRA:
			$Armature/Skeleton3D/NanahiraPapercraft.visible = true
		Character.NANAHI_2:
			_reskin(preload("res://models/characters/nanahira/skins/Nanahi.png"))
		Character.MUCHAHIRA_1:
			_reskin(preload("res://models/characters/nanahira/skins/MuchahiraPapercraft1.png"))
		Character.MUCHAHIRA_2:
			_reskin(preload("res://models/characters/nanahira/skins/MuchahiraPapercraft2.png"))
		Character.MUCHAHIRA_3:
			_reskin(preload("res://models/characters/nanahira/skins/MuchahiraPapercraft3.png"))
		Character.NANAHIRA_PIZZA:
			_reskin(preload("res://models/characters/nanahira/skins/PizzaPapercraft.png"))
		Character.MESSENGER:
			scene = preload("res://models/characters/messenger/messenger_papercraft.tscn")
			respath = "Armature/Skeleton3D/MessengerPapercraft"
		_:
			push_warning("Specified character not in enum, can't load!")
	
	if scene and respath:
		var instance = scene.instantiate()
		instance.get_node(respath).reparent($Armature/Skeleton3D, false)

func _process(delta):
	pass

func set_flight(flying: bool):
	if flying:
		$AnimationTree["parameters/playback"].travel("Fly")
	else:
		set_velocity(last_velocity)

func set_velocity(velocity: Vector3):
	last_velocity = velocity
	var v = Vector3(velocity.x, 0, velocity.z).length() * VELOCITY_SCALE
	if v > 0.01:
		var speed = clamp(0.75, 4, v)
		var blend = clamp(0.2, 1, v)
		$AnimationTree["parameters/playback"].travel("Walk")
		$AnimationTree.set("parameters/Walk/Blend2/blend_amount", blend);
		$AnimationTree["parameters/Walk/TimeScale/scale"] = speed
	else:
		$AnimationTree["parameters/playback"].travel("Idle")
		$AnimationTree["parameters/Walk/TimeScale/scale"] = 1.0
