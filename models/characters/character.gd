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
	MESSENGER_BLUE,
	MESSENGER_GOLD,
	MESSENGER_GREEN,
	MESSENGER_MAGENTA,
	MESSENGER_RED,
	MESSENGER_NPC_RANDOM,
}

const VELOCITY_SCALE = 2.0

var last_velocity = Vector3.ZERO
var in_flight = false

var _character: Character = Character.NANAHIRA
@export var character: Character:
	get:
		return _character
	set(value):
		_character = value
		update_character()

func _reskin(node, texture):
	node.visible = true
	var material: ShaderMaterial = node.get_surface_override_material(0)
	material = material.duplicate()
	material.set_shader_parameter("texture_paper", texture)
	node.set_surface_override_material(0, material)


func update_character():
	if not is_inside_tree():
		return
	if not has_node("Armature/Skeleton3D/NanahiraPapercraft"):
		await $Armature/Skeleton3D/NanahiraPapercraft.ready
	var scene = null
	var respath = null
	var skin = null

	if _character == Character.MESSENGER_NPC_RANDOM:
		_character = randi_range(Character.MESSENGER_BLUE, Character.MESSENGER_RED) as Character

	$Armature/Skeleton3D/NanahiraPapercraft.visible = false

	match(_character):
		Character.NANAHIRA:
			$Armature/Skeleton3D/NanahiraPapercraft.visible = true
		Character.NANAHI_2:
			_reskin($Armature/Skeleton3D/NanahiraPapercraft, preload("res://models/characters/nanahira/skins/Nanahi.png"))
		Character.MUCHAHIRA_1:
			_reskin($Armature/Skeleton3D/NanahiraPapercraft, preload("res://models/characters/nanahira/skins/MuchahiraPapercraft1.png"))
		Character.MUCHAHIRA_2:
			_reskin($Armature/Skeleton3D/NanahiraPapercraft, preload("res://models/characters/nanahira/skins/MuchahiraPapercraft2.png"))
		Character.MUCHAHIRA_3:
			_reskin($Armature/Skeleton3D/NanahiraPapercraft, preload("res://models/characters/nanahira/skins/MuchahiraPapercraft3.png"))
		Character.NANAHIRA_PIZZA:
			_reskin($Armature/Skeleton3D/NanahiraPapercraft, preload("res://models/characters/nanahira/skins/PizzaPapercraft.png"))
		Character.MESSENGER:
			scene = preload("res://models/characters/messenger/messenger_papercraft.tscn")
			respath = "Armature/Skeleton3D/MessengerPapercraft"
		Character.MESSENGER_BLUE:
			scene = preload("res://models/characters/messenger_npc/messenger_npc.tscn")
			respath = "Armature/Skeleton3D/MessengerPapercraftNPC"
			skin = preload("res://models/characters/messenger_npc/skins/NpcMessengerPapercraftBlue.png")
		Character.MESSENGER_GOLD:
			scene = preload("res://models/characters/messenger_npc/messenger_npc.tscn")
			respath = "Armature/Skeleton3D/MessengerPapercraftNPC"
			skin = preload("res://models/characters/messenger_npc/skins/NpcMessengerPapercraftGold.png")
		Character.MESSENGER_GREEN:
			scene = preload("res://models/characters/messenger_npc/messenger_npc.tscn")
			respath = "Armature/Skeleton3D/MessengerPapercraftNPC"
			skin = preload("res://models/characters/messenger_npc/skins/NpcMessengerPapercraftGreen.png")
		Character.MESSENGER_MAGENTA:
			scene = preload("res://models/characters/messenger_npc/messenger_npc.tscn")
			respath = "Armature/Skeleton3D/MessengerPapercraftNPC"
			skin = preload("res://models/characters/messenger_npc/skins/NpcMessengerPapercraftMagenta.png")
		Character.MESSENGER_RED:
			scene = preload("res://models/characters/messenger_npc/messenger_npc.tscn")
			respath = "Armature/Skeleton3D/MessengerPapercraftNPC"
			skin = preload("res://models/characters/messenger_npc/skins/NpcMessengerPapercraftRed.png")
		_:
			push_warning("Specified character not in enum, can't load!")

	if scene and respath:
		var instance = scene.instantiate()
		self.add_child(instance)
		var node = instance.get_node(respath)
		node.reparent($Armature/Skeleton3D, false)
		if skin:
			_reskin(node, skin)

func _process(delta):
	pass

func flap_wings():
	if in_flight:
		$AnimationTree["parameters/Wings/playback"].travel("Wing-flap")

func set_flight(flying: bool):
	if flying != in_flight:
		in_flight = flying
		$AnimationTree["parameters/Wings/playback"].travel("Wing-open" if flying else "RESET")

	if flying:
		$AnimationTree["parameters/Movement/playback"].travel("Fly")
	else:
		set_velocity(last_velocity)

func set_velocity(velocity: Vector3):
	last_velocity = velocity
	var v = Vector3(velocity.x, 0, velocity.z).length() * VELOCITY_SCALE
	if v > 0.01:
		var speed = clamp(0.75, 4, v)
		var blend = clamp(0.2, 1, v)
		$AnimationTree["parameters/Movement/playback"].travel("Walk")
		$AnimationTree.set("parameters/Movement/Walk/Blend2/blend_amount", blend);
		$AnimationTree["parameters/Movement/Walk/TimeScale/scale"] = speed
	else:
		$AnimationTree["parameters/Movement/playback"].travel("Idle")
		$AnimationTree["parameters/Movement/Walk/TimeScale/scale"] = 1.0
