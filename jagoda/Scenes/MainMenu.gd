extends Control

const GAME_SCENE: String = "res://Scenes/Game.tscn"
const CREDITS_SCENE: String = "res://Scenes/Credits.tscn"

@onready var loading = get_node("/root/Loading")

func _ready():
	if OS.get_name() != "Web":
		$MainVBox/MenuVBox/ExitButton.show()

func _on_play_button_pressed():
	self.hide()
	loading.load_scene(GAME_SCENE)

func _on_credits_button_pressed():
	get_tree().change_scene_to_file(CREDITS_SCENE)

func _on_exit_button_pressed():
	get_tree().quit(0)
