@icon("./amplitude.svg")
class_name AudioJitterPlayer
extends AudioStreamPlayer

@export_range(0.0, 0.5, 0.01) var jitter: float = 0.0
@export var base_pitch_scale: float = 1.0


func _ready() -> void:
	finished.connect(_on_playback_finished)


func play_jitter(from_position: float = 0.0) -> void:
	if jitter > 0.0:
		var pitch_factor = randf_range(-jitter, jitter)
		pitch_scale = base_pitch_scale * (1.0 + pitch_factor)
	else:
		pitch_scale = base_pitch_scale

	play(from_position)


func _on_playback_finished() -> void:
	pitch_scale = base_pitch_scale
