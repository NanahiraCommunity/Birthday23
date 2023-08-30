extends MarginContainer

var click_count: int = 0
var displayed_clicks: int = 0
var can_click: bool = false

var click1: int = 0
var click2: int = 0
var click3: int = 0

var scores = []

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$Drums/VBoxContainer2/Countdown.done.connect(_timeout)
	var name: String
	var i = 0
	for child in $Drums/VBoxContainer/Highscores/MarginContainer/ScrollContainer/GridContainer.get_children():
		if i % 2 == 0:
			name = child.text
		else:
			var score = int(child.text)
			scores.append([name, score])
			name = ""
		i += 1

func start():
	visible = true
	Global.block_player_ui += 1
	click_count = 0
	displayed_clicks = 0
	$Drums/VBoxContainer2/Countdown.text = "00:10"
	$Drums/VBoxContainer2/Counter.text = "GO! GO!! GO!!!"
	can_click = true

func _timeout():
	can_click = false
	var score = displayed_clicks
	$Drums/VBoxContainer2/Counter.text = "STOP！！！"
	await get_tree().create_timer(2.0).timeout
	$Drums/VBoxContainer2/Counter.text = "Your score: " + str(score)

	var container = $Drums/VBoxContainer/Highscores/MarginContainer/ScrollContainer/GridContainer
	var max_pos = container.get_child_count()
	var tree_pos = max_pos
	for i in range(0, scores.size()):
		if score > scores[i][1]:
			tree_pos = i * 2
			break

	var name_label = container.get_child(0).duplicate()
	name_label.text = tr("Messenger")
	var score_label = container.get_child(1).duplicate()
	score_label.text = str(score)
	container.add_child(name_label)
	container.add_child(score_label)

	scores.insert(tree_pos / 2, ["Messenger", score])
	if tree_pos < max_pos:
		container.move_child(name_label, tree_pos)
		container.move_child(score_label, tree_pos + 1)
	if score > Global.max_drum_score:
		Global.max_drum_score = score

func _input(event):
	if event is InputEventKey:
		if can_click and event.pressed and not event.echo and (event.physical_keycode == KEY_X or event.physical_keycode == KEY_Z):
			if not $Drums/VBoxContainer2/Countdown.active:
				$Drums/VBoxContainer2/Countdown.set_time(10)
			click()
			get_viewport().set_input_as_handled()
		elif visible and event.pressed and (event.is_action("ui_cancel") or event.is_action("ui_accept") or event.is_action_pressed("interact")) and not can_click:
			Global.block_player_ui -= 1
			visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick1.visible = click1 > 0
	$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick2.visible = click2 > 0
	$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick3.visible = click3 > 0
	
	if displayed_clicks < click_count and can_click:
		if displayed_clicks + 1000 < click_count:
			displayed_clicks += (click_count - displayed_clicks) / 10
		elif displayed_clicks + 246 < click_count:
			displayed_clicks += 246
		elif displayed_clicks + 19 < click_count:
			displayed_clicks += 19
		else:
			displayed_clicks = click_count
		$Drums/VBoxContainer2/Counter.text = str(displayed_clicks)

func click():
	if Global.boosted:
		$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick3.z_index += 1
		click_count += 1000
		click3 += 1
		await get_tree().create_timer(0.1).timeout
		click3 -= 1
	else:
		click_count += 1
		if click_count % 2 == 0:
			$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick1.z_index += 1
			click1 += 1
			await get_tree().create_timer(0.1).timeout
			click1 -= 1
		else:
			$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick2.z_index += 1
			click2 += 1
			await get_tree().create_timer(0.1).timeout
			click2 -= 1
