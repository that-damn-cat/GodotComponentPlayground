## An implementation of the Label control that can type out its contents one character
## at a time. Optionally takes a sound effect to play after each update.

@icon("./chat-bubble.svg")
class_name SpeechLabel
extends Label

## Emits when the whole dialogue is finished.
signal finished

## Emits when one or more characters got typed.
signal char_printed

## Label contents to type out
@export_multiline var dialogue: String

## Optional audio to play after each character.
@export var type_sound: AudioStreamPlayer

## Number of seconds between characters
@export var type_speed: float = 0.1:
	set(new_speed):
		type_speed = new_speed
		_timer.wait_time = new_speed

## Whether or not the label is in the process of typing its contents.
var is_playing: bool = false

var _timer: Timer = Timer.new()
var _next_char: int = 0


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


## Begin typing the dialogue contents into the label
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

## Type out the next character in the dialogue.
func print_next_char():
	if _next_char < dialogue.length():
		text = text + dialogue[_next_char]
		_next_char += 1
	else:
		# Otherwise, we're out of things to print!
		_timer.stop()
		finished.emit()
		is_playing = false

## Finish filling the label with the dialogue right now.
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
