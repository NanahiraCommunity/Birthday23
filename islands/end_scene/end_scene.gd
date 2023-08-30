extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	var end_text = $M/M/V/RichTextLabel
	var credits_text = $M/M/V/RichTextLabel2
	end_text.text = Global.preprocess_bbcode(tr("END_TEXT"))
	credits_text.text = (
		"[center]Credits[/center]"
	)
