class_name Player
extends CharacterBody2D

const WALK_SPEED = 200.0
const MAX_FRESHNESS_LOST_PER_SECOND = 10.0
const SIGHING_FRESHNESS_THRESHOLD = 50
const SIGHING_PERIOD = 10.0

signal player_freshness_changed(freshness)
signal player_plant_water_changed(plant_water)

var freshness: float = 100
var plant_water: float = 100
var current_sun_intensity = 0
var sighing: bool = false
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

	if Input.is_action_pressed("use-item") and self.plant_water > 0:
		if not $WaterParticles.emitting:
			$WaterParticles.emitting = true
		for plant in self.visible_plants.keys():
			plant.refresh(5.0 * delta)
		self.plant_water = max(self.plant_water - 10.0 * delta, 0)
		self.player_plant_water_changed.emit(self.plant_water)
	else:
		if $WaterParticles.emitting:
			$WaterParticles.emitting = false

	if walk_velocity.x != 0:
		$RefreshArea.scale.x = walk_velocity.x
		$WaterParticles.position.x = abs($WaterParticles.position.x) * walk_velocity.x
		$WaterParticles.scale.x = walk_velocity.x
		$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x) * (-sign(walk_velocity.x))

	if walk_velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")

	self.velocity = walk_velocity.normalized() * WALK_SPEED
	move_and_slide()
	
	var freshness_lost_per_second = self.current_sun_intensity * MAX_FRESHNESS_LOST_PER_SECOND
	self.freshness = max(self.freshness - freshness_lost_per_second * delta, 0)
	
	if not sighing and self.freshness < SIGHING_FRESHNESS_THRESHOLD:
		self._sigh()	
	
	self.player_freshness_changed.emit(self.freshness)

func _on_refresh_area_area_entered(area):
	if area is Plant:
		area.set_freshness_visible(true)
		self.visible_plants[area] = true
	
func _on_refresh_area_area_exited(area):
	if self.visible_plants.erase(area):
		area.set_freshness_visible(false)

func _sigh():
	if self.freshness >= SIGHING_FRESHNESS_THRESHOLD or is_equal_approx(self.freshness, 0):
		self.sighing = false
		return
	
	self.sighing = true
	if not $SighPlayer.playing:
		$SighPlayer.play()
		
	var timer = get_tree().create_timer(SIGHING_PERIOD)
	timer.timeout.connect(self._sigh)
