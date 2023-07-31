extends Node2D

const FRIDGE_PACKED_SCENE = preload("res://Scenes/Fridge.tscn")
const FRIDGE_SPRITE_FRAMES = [
	preload("res://Assets/Fridges/Fridge1/Fridge1SpriteFrames.tres"),
	preload("res://Assets/Fridges/Fridge2/Fridge2SpriteFrames.tres")
]
const MAX_SCORE: int = 1000
const FRIDGE_SPAWN_X_RANGE: float = 400.0
const FRIDGE_SPAWN_Y_OFFSET: float = 200.0
const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"
const DAY_LENGTH_MINUTES: float = 7
const DAY_LENGTH_SECONDS: float = DAY_LENGTH_MINUTES * 60
const MIN_LUMINANCE: float = 0.5
const MAX_LUMINANCE: float = 1.0
const LUMINANCE_RANGE: float = MAX_LUMINANCE - MIN_LUMINANCE
const MIN_SATURATION: float = 1.0
const MAX_SATURATION: float = 0.0
const SATURATION_RANGE: float = MAX_SATURATION - MIN_SATURATION
const GAME_DAYS: int = 7
const START_TIME_SECONDS: float = 6 * 3600 # 06:00
const END_TIME_SECONDS: float = 20 * 3600 # 20:00
const TIME_LABEL_UPDATE_PERIOD_MINUTES: float = 5

@onready var loading = get_node("/root/Loading")
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var sun: AnimatedSprite2D = $HUD/Sun
@onready var canvas_hue = canvas_modulate.color.h;
@onready var tree = get_tree()

var day = 0
var time_passed = 0
var previous_day_time = null
var plant_count_previous: int = 0
var plant_count: int = 0
var plant_count_total: int = 0

signal sun_intensity_changed(sun_intensity)
signal day_changed

func _ready():
	randomize()

	self._set_freshness_visible(false)
	
	sun_intensity_changed.connect($Player.on_sun_intensity_changed)
	$Player.player_freshness_changed.connect(self._on_player_freshness_changed)
	$Player.player_pick_up_fridge.connect(self._on_player_pick_up_fridge)
	$Player.player_drop_fridge.connect(self._on_player_drop_fridge)
	$Player.player_update_main_action.connect(self._on_player_update_main_action)
	$Player.player_update_use_action.connect(self._on_player_update_use_action)

	$Crib.crib_set_drinking_enabled.connect($Player.set_can_drink)

	day_changed.connect(self._on_day_changed)

	var plants = tree.get_nodes_in_group("plant")
	plant_count = plants.size()
	plant_count_previous = plant_count
	plant_count_total = plant_count
	for plant in plants:
		plant.plant_die.connect(self._on_plant_die)
		sun_intensity_changed.connect(plant.on_sun_intensity_changed)
		day_changed.connect(plant.on_day_changed)

	day_changed.emit()
	loading.on_loading_start.connect(self._on_loading_start)

	$HUD/DayCompletedMenu.day_completed_continue.connect(self._on_day_completed_continue)

	$HUD/Control/E.visible = false
	$HUD/Control/Space.visible = false

func _on_day_completed_continue():
	day_changed.emit()

func _set_freshness_visible(visible: bool):
	$HUD/ItemFreshnessBar.visible = visible
	$HUD/Droplet.visible = visible

func _on_player_update_main_action(text):
	if text == null:
		$HUD/Control/E.visible = false
	else:
		$HUD/Control/E/Label.text = text
		$HUD/Control/E.visible = true

func _on_player_update_use_action(text):
	if text == null:
		$HUD/Control/Space.visible = false
	else:
		$HUD/Control/Space/Label.text = text
		$HUD/Control/Space.visible = true

func _on_loading_start():
	$Player/Camera2D.queue_free()
	$HUD.hide()
	$ThemePlayer.stop()
	$HUD.set_process(false)
	self.hide()

func _on_plant_die():
	self.plant_count -= 1
	if self.plant_count == 0:
		self._game_over("All your plants are dead.")

func _on_player_freshness_changed(freshness):
	$HUD/PlayerFreshnessBar.value = freshness
	if is_equal_approx(freshness, 0):
		self._game_over("You died from dehydration.")

func _on_fridge_freshness_changed(freshness):
	$HUD/ItemFreshnessBar.value = freshness

func _on_player_pick_up_fridge(fridge):
	$HUD/ItemFreshnessBar.value = fridge.freshness
	self._set_freshness_visible(true)
	self.remove_child(fridge)

func _on_player_drop_fridge(fridge):
	self._set_freshness_visible(false)
	self.add_child(fridge)

func _on_day_changed():
	self.plant_count_previous = self.plant_count
	self.time_passed = 0
	self.day += 1
	self.previous_day_time = null
	$HUD/DayLabel.text = "Day {0} / {1}".format([day, GAME_DAYS])
	self._spawn_fridge()

func _spawn_fridge():
	var fridge = FRIDGE_PACKED_SCENE.instantiate()
	fridge.sprite_frames = FRIDGE_SPRITE_FRAMES[day % FRIDGE_SPRITE_FRAMES.size()]
	fridge.position.x = $Crib.position.x + randf_range(-FRIDGE_SPAWN_X_RANGE / 2, FRIDGE_SPAWN_X_RANGE / 2)
	fridge.position.y = $Crib.position.y + FRIDGE_SPAWN_Y_OFFSET
	fridge.fridge_freshness_changed.connect(self._on_fridge_freshness_changed)
	add_child(fridge)

func _input(event):
	if event.is_action_pressed("pause"):
		self._pause()

func _process(delta):
	if not self.visible:
		return

	var day_progress: float = min(time_passed / DAY_LENGTH_SECONDS, 1)
	var sun_intensity: float = sin(day_progress * PI)
	sun_intensity_changed.emit(sun_intensity)
	
	var screen_width = get_viewport_rect().size.x
	sun.position.x = day_progress * screen_width
	canvas_modulate.color.h = canvas_hue;
	canvas_modulate.color.v = sun_intensity * LUMINANCE_RANGE + MIN_LUMINANCE
	canvas_modulate.color.s = sun_intensity * SATURATION_RANGE + MIN_SATURATION
	time_passed += delta
	
	var day_time = START_TIME_SECONDS + day_progress * (END_TIME_SECONDS - START_TIME_SECONDS)
	var day_hours = floor(day_time / 3600)
	var day_minutes = floor((day_time - day_hours * 3600) / 60)
	if previous_day_time == null or (day_time - previous_day_time) >= TIME_LABEL_UPDATE_PERIOD_MINUTES * 60:
		$HUD/TimeLabel.text = "%02d:%02d" % [day_hours, self._round_step(day_minutes, TIME_LABEL_UPDATE_PERIOD_MINUTES)]
		previous_day_time = day_time
	
	if is_equal_approx(day_progress, 1):
		if self.day == GAME_DAYS:
			self._show_victory_screen()
		else:
			self._show_day_completed_screen()

func _show_victory_screen():
	var plant_ratio = self.plant_count / self.plant_count_total
	var avg_plant_freshness = self._get_avg_plant_freshness() / 100
	var avg_fridge_freshness = self._get_avg_fridge_freshness() / 100
	var metrics = [plant_ratio, avg_plant_freshness, avg_fridge_freshness]
	var denominator = 0
	for m in metrics:
		denominator += 1 / m
	var mean = metrics.size() / denominator if not is_equal_approx(denominator, 0) else 0
	var score: int = floor(mean * MAX_SCORE)
	$HUD/VictoryScreen.set_score(score, MAX_SCORE)
	$HUD/VictoryScreen.show()

func _show_day_completed_screen():
	var plants_lost = self.plant_count_previous - self.plant_count
	var avg_plant_freshness = self._get_avg_plant_freshness()
	var avg_fridge_freshness = self._get_avg_fridge_freshness()
	
	$HUD/DayCompletedMenu.set_stats(self.day, plants_lost, plant_count, plant_count_total, avg_plant_freshness, avg_fridge_freshness)
	$HUD/DayCompletedMenu.show()

func _get_avg_plant_freshness():
	var plants = tree.get_nodes_in_group("plant")
	if plants.is_empty():
		return 0

	var avg_plant_freshness = 0
	for plant in plants:
		avg_plant_freshness += plant.freshness
	avg_plant_freshness /= self.plant_count
	return avg_plant_freshness

func _get_avg_fridge_freshness():
	var fridges = tree.get_nodes_in_group("fridge")
	if $Player.fridge != null:
		fridges.append($Player.fridge)

	if fridges.is_empty():
		return 0

	var avg_fridge_freshness = 0
	for fridge in fridges:
		avg_fridge_freshness += fridge.freshness
	avg_fridge_freshness /= fridges.size()
	return avg_fridge_freshness

func _round_step(number: int, step: int):
	var times: int = floor(number / step)
	return times * step

func _pause():
	$HUD/PauseMenu.show()

func _game_over(reason: String):
	$HUD/GameOver.set_reason(reason)
	$HUD/GameOver.show()
