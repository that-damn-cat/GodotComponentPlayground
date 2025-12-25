## An implementation of AudioStreamPlayer that randomizes its own pitch to
## reduce the impact of repetitive sounds.

@icon("./amplitude.svg")
class_name AudioJitterPlayer
extends AudioStreamPlayer

## A proportion of the base pitch scale used for randomizing the pitch.
## Larger values create a larger variance in pitches.
@export_range(0.0, 0.5, 0.01) var jitter: float = 0.0

@onready var _base_pitch: float = pitch_scale


## Call this instead of play() to apply pitch jitter.
func play_jitter(from_position: float = 0.0) -> void:
	pitch_scale = _get_jittered_pitch()
	play(from_position)


func _get_jittered_pitch() -> float:
	if jitter <= 0.0:
		return(_base_pitch)

	var factor := randf_range(-jitter, jitter)
	return(_base_pitch * (1.0 + factor))