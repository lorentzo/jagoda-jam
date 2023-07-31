extends Control

const MAIN_MENU_SCENE: String = "res://Scenes/MainMenu.tscn"

func _on_back_button_pressed():
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
