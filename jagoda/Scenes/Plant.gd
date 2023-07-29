class_name Plant
extends Area2D

const MAX_FRESHNESS: float = 100.0
const MAX_FRESHNESS_LOST_PER_SECOND: float = 0.5
const FRESHNESS_GAINED_PER_SECOND: float = 5.0
const DAY_MULTIPLIER_DEVIATION: float = 0.5
const PROGRESS_BAR_MARGIN: int = 10

var freshness: float = MAX_FRESHNESS
var day = 0
var current_sun_intensity = 0
var day_multiplier: float = 1.0
var difficulty_multiplier: float = 1.0

@export var sprite_frames: SpriteFrames = null
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready():
	if sprite_frames == null:
		return

	$AnimatedSprite2D.sprite_frames = sprite_frames
	$AnimatedSprite2D.play("idle")
	
	var collision_shape_size = max($CollisionShape2D.shape.radius * 2, $CollisionShape2D.shape.height)
	var frame_tex: Texture2D = $AnimatedSprite2D.sprite_frames.get_frame_texture("idle", 0)
	var scale = collision_shape_size / frame_tex.get_width()
	$AnimatedSprite2D.scale = Vector2(scale, scale)
	
	progress_bar.position.y = -(collision_shape_size / 2 + PROGRESS_BAR_MARGIN)


func _process(delta):
	var freshness_lost_per_second = self.difficulty_multiplier * self.current_sun_intensity * MAX_FRESHNESS_LOST_PER_SECOND * self.day_multiplier
	self.freshness = max(self.freshness - freshness_lost_per_second * delta, 0)
	progress_bar.value = round(freshness)
	
	if is_equal_approx(self.freshness, 0):
		_die()

func _die():
	queue_free()

func refresh(delta):
	self.freshness = min(self.freshness + FRESHNESS_GAINED_PER_SECOND * delta, MAX_FRESHNESS)

func set_freshness_visible(value: bool):
	progress_bar.visible = value

func on_sun_intensity_changed(sun_intensity):
	self.current_sun_intensity = sun_intensity

func on_day_changed():
	self.day += 1
	var deviation_integer = round(DAY_MULTIPLIER_DEVIATION * 100)
	var day_multiplier_integer = randi_range(100 - deviation_integer, 100 + deviation_integer)
	self.day_multiplier = day_multiplier_integer / 100.0
	self.difficulty_multiplier = 1 + 0.5 * (self.day - 1)
