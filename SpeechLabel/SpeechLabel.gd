@icon("./chat-bubble.svg")
class_name SpeechLabel
extends Label

## Emits when the whole dialogue is finished.
signal finished
## Emits when one or more characters got typed.
signal char_printed

@export_multiline var dialogue: String
@export var type_sound: AudioStreamPlayer
@export var type_speed: float = 0.1:
	set(new_speed):
		type_speed = new_speed
		_timer.wait_time = new_speed

var is_playing: bool = false
var _timer: Timer = Timer.new()
var _next_char: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up the internal timer for the typing effect
	_timer.autostart = false
	_timer.name = "TypeDelay"
	_timer.one_shot = false
	_timer.wait_time = type_speed
	_timer.timeout.connect(_on_character_timeout)
	add_child(_timer)

	# Clear any text in the label to start
	text = ""


func start() -> void:
	# In case the node is being re-used (we replace the dialogue and run it again after it finishes)
	text = ""
	_next_char = 0

	if dialogue.length() > 0:
		# Length 0 on empty string, which would break other scripts. Handle that here.
		_timer.start()
		is_playing = true
	else:
		# Running an empty dialogue means we instantly finish.
		finished.emit()
		is_playing = false


func print_next_char():
	if _next_char < dialogue.length():
		text = text + dialogue[_next_char]
		_next_char += 1
	else:
		# Otherwise, we're out of things to print!
		_timer.stop()
		finished.emit()
		is_playing = false


func skip() -> void:
	_timer.stop()

	for character in range(_next_char, dialogue.length()):
		text = text + dialogue[character]

	char_printed.emit()
	finished.emit()
	is_playing = false


func _on_character_timeout():
	print_next_char()

	if type_sound != null:
		if type_sound is AudioJitterPlayer:
			type_sound.play_jitter()
		else:
			type_sound.play()

	char_printed.emit()
