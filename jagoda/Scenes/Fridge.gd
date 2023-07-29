class_name Fridge
extends Area2D

@export var sprite_frames: SpriteFrames = null

func _ready():
	if sprite_frames == null:
		return

	$AnimatedSprite2D.sprite_frames = sprite_frames
	$AnimatedSprite2D.play("idle")

	var collision_shape_size = max($CollisionShape2D.shape.size.x, $CollisionShape2D.shape.size.y)
	var frame_tex: Texture2D = $AnimatedSprite2D.sprite_frames.get_frame_texture("idle", 0)
	var scale = collision_shape_size / frame_tex.get_width()
	$AnimatedSprite2D.scale = Vector2(scale, scale)
