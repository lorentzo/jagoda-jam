extends Control

const MAIN_MENU_SCENE: String = "res://Scenes/MainMenu.tscn"

@onready var loading = get_node("/root/Loading")

func _on_visibility_changed():
	var tree = get_tree()
	if tree == null:
		return
	tree.paused = self.visible

func _on_exit_button_pressed():
	self.hide()
	loading.load_scene(MAIN_MENU_SCENE)

func set_score(score: int, max_score: int):
	$MainVBox/ScoreLabel.text = "Score: %d / %d" % [score, max_score]
