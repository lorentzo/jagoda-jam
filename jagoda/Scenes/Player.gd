class_name Player
extends CharacterBody2D

enum State {
	WALK,
	CARRY
}

const WALK_SPEED = 200.0
const MAX_FRESHNESS = 100.0
const MAX_FRESHNESS_LOST_PER_SECOND = 1.0
const DRINK_FRESHNESS_GAINED_PERCENTAGE = 0.25
const SIGHING_FRESHNESS_THRESHOLD = 50
const SIGHING_PERIOD = 10.0

signal player_freshness_changed(freshness)
signal player_pick_up_fridge(fridge)
signal player_drop_fridge(fridge)
signal player_update_main_action(text)
signal player_update_use_action(text)

@onready var players: Array[AudioStreamPlayer] = [$CanPlayer, $DrinkPlayer]

var state = State.WALK
var freshness: float = 100
var can_drink: bool = false
var current_sun_intensity = 0
var sighing: bool = false
var visible_plants: Dictionary = {}
var visible_fridges: Dictionary = {}
var fridge: Fridge = null
var is_drinking_sound_playing = false

func on_sun_intensity_changed(sun_intensity):
	self.current_sun_intensity = sun_intensity

func set_can_drink(value: bool):
	self.can_drink = value
	self._update_actions()

func _ready():
	randomize()
	
	for player in players:
		player.finished.connect(self._on_drinking_sound_finished)

func _on_drinking_sound_finished():
	self.is_drinking_sound_playing = false

func _physics_process(delta):
	if self.is_drinking_sound_playing:
		return
	
	var walk_velocity = Vector2.ZERO
	
	if Input.is_action_pressed("walk-left"):
		walk_velocity.x = -1
	elif Input.is_action_pressed("walk-right"):
		walk_velocity.x = 1
	
	if Input.is_action_pressed("walk-up"):
		walk_velocity.y = -1
	elif Input.is_action_pressed("walk-down"):
		walk_velocity.y = 1

	if Input.is_action_just_pressed("use-item"):
		if state == State.CARRY and not fridge.is_empty():
			fridge.activate()
	elif Input.is_action_just_released("use-item"):
		if state == State.CARRY:
			fridge.deactivate()
	
	var refreshing = fridge != null and fridge.is_active()
	$WaterParticles.emitting = refreshing
	if refreshing:
		for plant in self.visible_plants.keys():
			plant.refresh(delta)
		fridge.process(delta)

	if Input.is_action_just_pressed("main"):
		if state == State.WALK:
			if not self.visible_fridges.is_empty():
				self.fridge = self._get_current_fridge()
				self.visible_fridges.erase(self.fridge)
				self.player_pick_up_fridge.emit(self.fridge)
				$PickupPlayer.play()
				state = State.CARRY
				self._update_fridge_indicators()
				self._update_actions()				
			elif can_drink:
				self._drink()
				return
		elif state == State.CARRY:
			var fridge = self.fridge
			self.fridge = null
			fridge.deactivate()
			fridge.position = self.position
			self.player_drop_fridge.emit(fridge)
			$DropPlayer.play()
			state = State.WALK
			self._update_fridge_indicators()
			self._update_actions()

	if walk_velocity.x != 0:
		$RefreshArea.scale.x = walk_velocity.x
		$WaterParticles.position.x = abs($WaterParticles.position.x) * walk_velocity.x
		$WaterParticles.scale.x = walk_velocity.x
		$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x) * sign(walk_velocity.x)

	if walk_velocity != Vector2.ZERO:
		var animation = "walk"
		if state == State.CARRY:
			animation += "_fridge%d" % [self.fridge.get_variant()]
		$AnimatedSprite2D.play(animation)
	elif refreshing and state == State.CARRY:
		var animation = "refresh_plants_fridge%d" % [self.fridge.get_variant()]
		$AnimatedSprite2D.play(animation)
	else:
		var animation = "idle"
		if state == State.CARRY:
			animation += "_fridge%d" % [self.fridge.get_variant()]
		$AnimatedSprite2D.play(animation)

	self.velocity = walk_velocity.normalized() * WALK_SPEED
	move_and_slide()
	
	var freshness_lost_per_second = self.current_sun_intensity * MAX_FRESHNESS_LOST_PER_SECOND
	self.freshness = max(self.freshness - freshness_lost_per_second * delta, 0)
	
	if not sighing and self.freshness < SIGHING_FRESHNESS_THRESHOLD:
		self._sigh()	
	
	self.player_freshness_changed.emit(self.freshness)

func _get_current_fridge() -> Fridge:
	if self.visible_fridges.is_empty():
		return null
	return self.visible_fridges.keys()[0]

func _update_fridge_indicators():
	if state == State.WALK:
		var current_fridge = _get_current_fridge()
		if current_fridge == null:
			return

		current_fridge.set_indicator_visible(true)
		for fridge in self.visible_fridges.keys():
			if fridge != current_fridge:
				fridge.set_indicator_visible(false)
	elif state == State.CARRY:
		for fridge in self.visible_fridges.keys():
			fridge.set_indicator_visible(false)

func _on_refresh_area_area_entered(area):
	if area is Plant:
		area.set_freshness_visible(true)
		self.visible_plants[area] = true
	elif area is Fridge:
		self.visible_fridges[area] = true
		self._update_fridge_indicators()
		self._update_actions()
	
func _on_refresh_area_area_exited(area):
	if area is Plant:
		if self.visible_plants.erase(area):
			area.set_freshness_visible(false)
	elif area is Fridge:
		self.visible_fridges.erase(area)
		area.set_indicator_visible(false)
		self._update_fridge_indicators()
		self._update_actions()

func _update_actions():
	var main_action = null
	var use_action = null
	if state == State.WALK:
		if self.visible_fridges.is_empty():
			if self.can_drink:
				main_action = "Drink"
		else:
			main_action = "Pick Up"
	elif state == State.CARRY:
		main_action = "Drop"
		use_action = "Use (hold)"

	self.player_update_main_action.emit(main_action)
	self.player_update_use_action.emit(use_action)

func _sigh():
	if self.freshness >= SIGHING_FRESHNESS_THRESHOLD or is_equal_approx(self.freshness, 0):
		self.sighing = false
		return
	
	self.sighing = true
	if not $SighPlayer.playing:
		$SighPlayer.play()
		
	var timer = get_tree().create_timer(SIGHING_PERIOD)
	timer.timeout.connect(self._sigh)

func _drink():
	self.freshness = min(self.freshness + DRINK_FRESHNESS_GAINED_PERCENTAGE * MAX_FRESHNESS, MAX_FRESHNESS)
	
	$AnimatedSprite2D.play("drink")	
	
	var player = players[randi() % players.size()]
	player.play()
	self.is_drinking_sound_playing = true
