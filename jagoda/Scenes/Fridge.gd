class_name Fridge
extends Area2D

enum State {
	IDLE,
	ACTIVE
}

const FRESHNESS_USED_PER_SECOND: float = 10.0
const PROGRESS_BAR_MARGIN: int = 10
const INDICATOR_MARGIN: int = 20

signal fridge_freshness_changed(freshness)

@export var sprite_frames: SpriteFrames = null

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var indicator: Polygon2D = $Indicator

var state = State.IDLE
var freshness: float = 100

func _ready():
	if sprite_frames == null:
		return

	$AnimatedSprite2D.sprite_frames = sprite_frames
	$AnimatedSprite2D.play("idle")

	var collision_shape_size = max($CollisionShape2D.shape.size.x, $CollisionShape2D.shape.size.y)
	var frame_tex: Texture2D = $AnimatedSprite2D.sprite_frames.get_frame_texture("idle", 0)
	var scale = collision_shape_size / frame_tex.get_width()
	$AnimatedSprite2D.scale = Vector2(scale, scale)

	progress_bar.visible = false
	progress_bar.position.y = -(collision_shape_size / 2 + PROGRESS_BAR_MARGIN)

	indicator.visible = false
	indicator.position.y = progress_bar.position.y - INDICATOR_MARGIN

func process(delta):
	if state == State.ACTIVE:
		self.freshness = max(self.freshness - FRESHNESS_USED_PER_SECOND * delta, 0)
		self.fridge_freshness_changed.emit(self.freshness)

	if self.is_empty():
		state = State.IDLE

func _process(delta):
	self.progress_bar.value = self.freshness

func activate():
	state = State.ACTIVE

func deactivate():
	state = State.IDLE

func set_indicator_visible(value: bool):
	self.indicator.visible = value

func is_empty():
	return is_equal_approx(self.freshness, 0)

func is_active():
	return state == State.ACTIVE
