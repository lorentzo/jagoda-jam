extends Node2D

@onready var players: Array[AudioStreamPlayer] = [$CanPlayer, $DrinkPlayer]
var playing = false

func _ready():
	for player in players:
		player.finished.connect(self._on_player_finished)

func _process(delta):
	# TODO Just for testing; remove later
#	if not self.playing and Input.is_key_pressed(KEY_E):
#		var player = $CanPlayer if randf() > 0.5 else $DrinkPlayer
#		player.play()
#		self.playing = true
	pass

func _on_body_entered(body):
	if body is Player:
		# TODO
		print("Enter: ", body)

func _on_body_exited(body):
	if body is Player:
		# TODO
		print("Exit: ", body)

func _on_player_finished():
	self.playing = false
