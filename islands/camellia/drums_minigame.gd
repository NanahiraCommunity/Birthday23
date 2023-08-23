extends MarginContainer

var click_count: int = 0
var displayed_clicks: int = 0
var can_click: bool = false

var click1: int = 0
var click2: int = 0
var click3: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	$Drums/VBoxContainer2/Countdown.done.connect(_timeout)

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
	$Drums/VBoxContainer2/Counter.text = "STOP！！！"
	await get_tree().create_timer(2.0).timeout
	$Drums/VBoxContainer2/Counter.text = "Your score: " + str(click_count)

func _input(event):
	if event is InputEventKey:
		if can_click and event.pressed and not event.echo and (event.physical_keycode == KEY_X or event.physical_keycode == KEY_Z):
			if not $Drums/VBoxContainer2/Countdown.active:
				$Drums/VBoxContainer2/Countdown.set_time(10)
			click()
			get_viewport().set_input_as_handled()
		elif event.pressed and event.is_action("ui_cancel"):
			Global.block_player_ui -= 1
			visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick1.visible = click1 > 0
	$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick2.visible = click2 > 0
	$Drums/VBoxContainer2/AspectRatioContainer/TextureRectClick3.visible = click3 > 0
	
	if displayed_clicks < click_count:
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
