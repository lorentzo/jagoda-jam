extends Control

@onready var loading = get_node("/root/Loading")

func _on_play_button_pressed():
	loading.load_scene("res://Scenes/Game.tscn")
