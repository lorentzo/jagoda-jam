class_name Player
extends CharacterBody2D

const WALK_SPEED = 150.0
const MAX_FRESHNESS_LOST_PER_SECOND = 1.0

signal player_freshness_changed(freshness)

var freshness: float = 100
var current_sun_intensity = 0
var visible_plants: Dictionary = {}

func on_sun_intensity_changed(sun_intensity):
	self.current_sun_intensity = sun_intensity

func _physics_process(delta):
	var walk_velocity = Vector2.ZERO
	
	if Input.is_action_pressed("walk-left"):
		walk_velocity.x = -1
	elif Input.is_action_pressed("walk-right"):
		walk_velocity.x = 1
	
	if Input.is_action_pressed("walk-up"):
		walk_velocity.y = -1
	elif Input.is_action_pressed("walk-down"):
		walk_velocity.y = 1

	if Input.is_action_pressed("use-item"):
		for plant in self.visible_plants.keys():
			plant.refresh(5.0 * delta)

	if walk_velocity.x != 0:
		$RefreshArea.scale.x = walk_velocity.x

	self.velocity = walk_velocity.normalized() * WALK_SPEED
	move_and_slide()
	
	var freshness_lost_per_second = self.current_sun_intensity * MAX_FRESHNESS_LOST_PER_SECOND
	self.freshness = max(self.freshness - freshness_lost_per_second * delta, 0)
	self.player_freshness_changed.emit(self.freshness)

func _on_refresh_area_area_entered(area):
	if area is Plant:
		area.set_freshness_visible(true)
		self.visible_plants[area] = true
	
func _on_refresh_area_area_exited(area):
	if self.visible_plants.erase(area):
		area.set_freshness_visible(false)
