extends Node2D

signal crib_set_drinking_enabled(enabled: bool)

var fridges: Dictionary = {}

func _process(delta):
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
		area.set_animation("charging")
		fridges[area] = true

func _on_area_exited(area):
	if area is Fridge:
		area.set_freshness_visible(false)
		area.set_animation("idle")
		fridges.erase(area)


