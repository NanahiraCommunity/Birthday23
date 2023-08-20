extends Label

var remaining_countdown: float = 0.0
var last_render_time: int = 0
var aborted: bool = false

signal done
signal tick(abort: bool)

func reset():
	visible = false
	aborted = true
	tick.emit(false)

func set_time(time: float):
	rerender()
	aborted = true
	tick.emit(false)
	remaining_countdown = time

func _process(delta):
	if remaining_countdown > 0.0 and visible:
		remaining_countdown -= delta
		if remaining_countdown < 0.0:
			remaining_countdown = 0.0
		var total = int(ceil(remaining_countdown))
		if total != last_render_time:
			rerender()
			aborted = false
			tick.emit(true)

		if remaining_countdown == 0.0:
			done.emit()
			visible = false

func rerender():
	var total = int(ceil(remaining_countdown))
	last_render_time = total
	var mins = total / 60
	var secs = total % 60
	render_time(mins, secs)

func render_time(mins: int, secs: int):
	text = "%02d:%02d" % [mins, secs]
