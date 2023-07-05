extends Node2D

const DAY_LENGTH_MINUTES: int = 7
const DAY_LENGTH_SECONDS: int = DAY_LENGTH_MINUTES * 60
const MIN_LUMINANCE: float = 0.3
const MAX_LUMINANCE: float = 1.0
const LUMINANCE_RANGE: float = MAX_LUMINANCE - MIN_LUMINANCE

@onready var canvas_modulate: CanvasModulate = $CanvasModulate

var time_passed = 0

func _process(delta):
	var sun_intensity = sin(time_passed / DAY_LENGTH_SECONDS * PI)
	canvas_modulate.color.v = sun_intensity * LUMINANCE_RANGE + MIN_LUMINANCE
	time_passed += delta
