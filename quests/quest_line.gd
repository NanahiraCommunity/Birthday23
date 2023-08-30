@tool
extends MarginContainer

var _text: String
@export var text: String:
	get:
		return _text
	set(value):
		_text = value
		if has_node("HBoxContainer/MarginContainer/Label"):
			if Engine.is_editor_hint():
				get_node("HBoxContainer/MarginContainer/Label").text = value
			else:
				get_node("HBoxContainer/MarginContainer/Label").text = Global.preprocess_bbcode(value)

var _finished: bool
@export var finished: bool:
	get:
		return _finished
	set(value):
		_finished = value
		if $HBoxContainer/Finished:
			$HBoxContainer/Finished.visible = value
			$HBoxContainer/Unfinished.visible = not value

var freeing: bool = false

func _ready():
	text = _text
	finished = _finished

func mark_finished():
	finished = true

func show_animated():
	if $AnimationPlayer and $AnimationPlayer.has_animation("show"):
		$AnimationPlayer.play("show")
		await $AnimationPlayer.animation_finished

func hide_animated():
	if $AnimationPlayer and $AnimationPlayer.has_animation("hide"):
		$AnimationPlayer.play("hide")
		await $AnimationPlayer.animation_finished

func hide_animated_and_free(timeout: float = 0.0):
	assert(not freeing, "attempted to animated free twice")
	freeing = true
	if not is_inside_tree():
		queue_free()
		return

	if timeout > 0.0:
		await get_tree().create_timer(timeout).timeout
	await hide_animated()
	var tween = get_tree().create_tween()
	$Panel.custom_minimum_size.y = size.y
	$HBoxContainer.queue_free()
	tween.set_ease(Tween.EASE_OUT).tween_property($Panel, "custom_minimum_size:y", 0, 0.15)
	await tween.finished
	queue_free()
