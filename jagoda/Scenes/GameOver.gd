extends Control

const MAIN_MENU_SCENE: String = "res://Scenes/MainMenu.tscn"
const GAME_SCENE: String = "res://Scenes/Game.tscn"

@onready var loading = get_node("/root/Loading")

func _on_visibility_changed():
	var tree = get_tree()
	if tree == null:
		return
	tree.paused = self.visible

func _on_retry_button_pressed():
	loading.load_scene(GAME_SCENE)

func _on_exit_button_pressed():
	loading.load_scene(MAIN_MENU_SCENE)
