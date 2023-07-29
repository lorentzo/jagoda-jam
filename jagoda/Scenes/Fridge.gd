class_name Fridge
extends Area2D

enum State {
	IDLE,
	ACTIVE
}

const FRESHNESS_USED_PER_SECOND: float = 10.0

signal fridge_freshness_changed(freshness)

@export var sprite_frames: SpriteFrames = null

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

func process(delta):
	if state == State.ACTIVE:
		self.freshness = max(self.freshness - FRESHNESS_USED_PER_SECOND * delta, 0)
		self.fridge_freshness_changed.emit(self.freshness)

	if self.is_empty():
		state = State.IDLE

func activate():
	state = State.ACTIVE

func deactivate():
	state = State.IDLE

func is_empty():
	return is_equal_approx(self.freshness, 0)

func is_active():
	return state == State.ACTIVE
