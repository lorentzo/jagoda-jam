extends Control

const MAIN_MENU_SCENE: String = "res://Scenes/MainMenu.tscn"

@onready var loading = get_node("/root/Loading")

func _on_visibility_changed():
	var tree = get_tree()
	if tree == null:
		return
	tree.paused = self.visible

func _input(event):
	if self.visible and event.is_action_pressed("pause"):
		self.accept_event()
		self.hide()

func _on_resume_button_pressed():
	self.hide()

func _on_exit_button_pressed():
	self.hide()
	loading.load_scene(MAIN_MENU_SCENE)
