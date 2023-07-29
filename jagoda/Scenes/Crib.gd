extends Node2D

signal crib_set_drinking_enabled(enabled: bool)

@onready var players: Array[AudioStreamPlayer] = [$CanPlayer, $DrinkPlayer]

var playing = false
var fridges: Dictionary = {}

func _ready():
	for player in players:
		player.finished.connect(self._on_player_finished)

func _process(delta):
	# TODO Just for testing; remove later
#	if not self.playing and Input.is_key_pressed(KEY_E):
#		var player = $CanPlayer if randf() > 0.5 else $DrinkPlayer
#		player.play()
#		self.playing = true

	for fridge in self.fridges.keys():
		fridge.refill(delta)

func _on_body_entered(body):
	if body is Player:
		self.crib_set_drinking_enabled.emit(true)

func _on_body_exited(body):
	if body is Player:
		self.crib_set_drinking_enabled.emit(false)

func _on_area_entered(area):
	if area is Fridge:
		area.set_freshness_visible(true)
		fridges[area] = true

func _on_area_exited(area):
	if area is Fridge:
		area.set_freshness_visible(false)
		fridges.erase(area)

func _on_player_finished():
	self.playing = false
