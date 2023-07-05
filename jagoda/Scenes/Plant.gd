extends Sprite2D

const MAX_FRESHNESS_LOST_PER_SECOND: float = 0.5
const DAY_MULTIPLIER_DEVIATION: float = 0.5

var freshness: float = 100
var current_sun_intensity = 0
var day_multiplier: float = 1.0

@onready var progress_bar: ProgressBar = $ProgressBar

func _process(delta):
	var freshness_lost_per_second = self.current_sun_intensity * MAX_FRESHNESS_LOST_PER_SECOND * self.day_multiplier
	self.freshness = max(self.freshness - freshness_lost_per_second * delta, 0)
	progress_bar.value = round(freshness)
	
	if is_equal_approx(self.freshness, 0):
		_die()

func _die():
	queue_free()

func on_sun_intensity_changed(sun_intensity):
	self.current_sun_intensity = sun_intensity

func on_day_changed():
	var deviation_integer = round(DAY_MULTIPLIER_DEVIATION * 100)
	var day_multiplier_integer = randi_range(100 - deviation_integer, 100 + deviation_integer)
	self.day_multiplier = day_multiplier_integer / 100.0
