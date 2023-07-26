extends Node2D

func _process(delta):
	# TODO Just for testing; remove later
	if not $CanPlayer.playing and Input.is_key_pressed(KEY_E):
		$CanPlayer.play()
