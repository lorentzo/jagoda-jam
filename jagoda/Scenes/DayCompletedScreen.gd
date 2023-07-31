extends Control

func _on_visibility_changed():
	var tree = get_tree()
	if tree == null:
		return
	tree.paused = self.visible

func _on_continue_button_pressed():
	self.hide()

func set_stats(day: int, plants_lost: int, plants_alive: int, plants_total: int, avg_plant_freshness: int, avg_fridge_freshness: int):
	$MainVBox/DayLabel.text = "Day %d Completed!" % [day]
	$MainVBox/StatsVBox/PlantsLostLabel.text = "Plants Lost: %d" % [plants_lost]
	$MainVBox/StatsVBox/PlantsAliveLabel.text = "Plants Alive: %d / %d" % [plants_alive, plants_total]
	$MainVBox/StatsVBox/AveragePlantFreshnessLabel.text = "Avg. Plant Freshness: %d %%" % [avg_plant_freshness]
	$MainVBox/StatsVBox/AverageFridgeFreshnessLabel.text = "Avg. Fridge Freshness: %d %%" % [avg_fridge_freshness]
