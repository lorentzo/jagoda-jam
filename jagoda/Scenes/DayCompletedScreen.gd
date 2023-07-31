extends Control

func _on_visibility_changed():
	var tree = get_tree()
	if tree == null:
		return
	tree.paused = self.visible

func _on_continue_button_pressed():
	self.hide()
