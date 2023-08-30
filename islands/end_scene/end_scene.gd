extends Control

const CREDITS = [
	"Project Lead",
	"\tWebFreak",
	"",
	"Character Lead",
	"\tCharacters based on work by くるみあべしさん @kurumiabeshi",
	"",
	"\tIjalRamd",
	"",
	"Creative Lead",
	"\tUngrave",
	"",
	"Code",
	"\tWebFreak",
	"\tlightbulbMEOW!!!",
	"\tikz87",
	"\tNicocchi",
	"\tGammA-su",
	"\tattosizemir",
	"",
	"Music",
	"\tHappydiamo",
	"\tKarl with a K",
	"\tSpark Miku Miku",
	"",
	"Sound Effects",
	"\tWebFreak",
	"\tazunyan",
	"\tShizuka",
	"\tIjalRamd",
	"",
	"3D Artists",
	"\tWebFreak",
	"\tblobbyfr",
	"",
	"2D Artists",
	"\tIjalRamd",
	"\tlightbulbMEOW!!!",
	"\tWebFreak",
	"",
	"Level Design",
	"\tKamppix",
	"\tlightbulbMEOW!!!",
	"\tWebFreak",
	"",
	"Internationalization",
	"\tLiz Hasegawa",
	"\tライスCake",
	"\tUngrave",
	"",
	"Playtesters",
	"\tライスCake",
	"\tTopaz",
	"\tNicocchi",
	"\tHappydiamo",
	"\tazunyan",
	"\tIjalRamd",
	"\tUngrave",
	"",
	"CREDITS_HAPPY_BIRTHDAY",
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var end_label = $M/M/V/RichTextLabel
	var credits_label = $M/M/V/RichTextLabel2
	end_label.text = Global.preprocess_bbcode(tr("END_TEXT"))
	var credits_text = ""
	for line in CREDITS:
		if not line.begins_with("\t") and line:
			credits_text += Global.preprocess_bbcode("[b]" + tr(line) + "[/b]\n")
		else:
			credits_text += line + "\n"
	credits_label.text = "[center]Credits[/center]\n" + credits_text
	$M.position.y = get_viewport().get_window().size.y

func _process(delta):
	$M.position.y -= delta * 30
