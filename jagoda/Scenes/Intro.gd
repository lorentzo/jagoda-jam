extends Control

const GAME_SCENE: String = "res://Scenes/Game.tscn"

@onready var loading = get_node("/root/Loading")

func _on_button_pressed():
	self.hide()
	loading.load_scene(GAME_SCENE)
