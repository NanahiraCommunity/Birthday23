extends CharacterBody3D

# duplicate in Global.gd
enum Type
{
	MIXED,
	TWO_SIZE,
	SORTED_PACKAGES,
	SORTED_LETTERS,
}

@export var type: Type = Type.MIXED

var items = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("carts")

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

func is_sorted():
	return type == Type.SORTED_PACKAGES or type == Type.SORTED_LETTERS

func has_items():
	return items > 0

func notify_letter(letter):
	items += 1
	letter.reparent(self)

func clear():
	items = 0
