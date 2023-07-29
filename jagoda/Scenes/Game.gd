extends Node2D

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
@onready var sun: Sprite2D = $HUD/Sun
@onready var screen_width = get_viewport().size.x
@onready var canvas_hue = canvas_modulate.color.h;
@onready var tree = get_tree()

var day = 0
var time_passed = 0
var previous_day_time = null

signal sun_intensity_changed(sun_intensity)
signal day_changed

func _ready():
	$HUD/Freshness.visible = false
	
	sun_intensity_changed.connect($Player.on_sun_intensity_changed)
	$Player.player_freshness_changed.connect(self._on_player_freshness_changed)
	$Player.player_pick_up_fridge.connect(self._on_player_pick_up_fridge)
	$Player.player_drop_fridge.connect(self._on_player_drop_fridge)
	
	day_changed.connect(self._on_day_changed)
	
	for plant in tree.get_nodes_in_group("plant"):
		sun_intensity_changed.connect(plant.on_sun_intensity_changed)
		day_changed.connect(plant.on_day_changed)
		
	for fridge in tree.get_nodes_in_group("fridge"):
		fridge.fridge_freshness_changed.connect(self._on_fridge_freshness_changed)

	day_changed.emit()
	loading.on_loading_start.connect(self._on_loading_start)

func _on_loading_start():
	$Player/Camera2D.queue_free()
	$HUD.hide()
	$ThemePlayer.stop()
	$HUD.set_process(false)
	self.hide()

func _on_player_freshness_changed(freshness):
	$HUD/PlayerFreshnessBar.value = freshness
	if is_equal_approx(freshness, 0):
		self._game_over()

func _on_fridge_freshness_changed(freshness):
	$HUD/Freshness/ItemFreshnessBar.value = freshness

func _on_player_pick_up_fridge(fridge):
	$HUD/Freshness/ItemFreshnessBar.value = fridge.freshness
	$HUD/Freshness.visible = true
	self.remove_child(fridge)

func _on_player_drop_fridge(fridge):
	$HUD/Freshness.visible = false
	self.add_child(fridge)

func _on_day_changed():
	self.time_passed = 0
	self.day += 1
	self.previous_day_time = null
	$HUD/DayLabel.text = "Day {0} / {1}".format([day, GAME_DAYS])

func _input(event):
	if event.is_action_pressed("pause"):
		self._pause()

func _process(delta):
	var day_progress: float = min(time_passed / DAY_LENGTH_SECONDS, 1)
	var sun_intensity: float = sin(day_progress * PI)
	sun_intensity_changed.emit(sun_intensity)
	
	sun.position.x = day_progress * screen_width
	canvas_modulate.color.h = canvas_hue;
	canvas_modulate.color.v = sun_intensity * LUMINANCE_RANGE + MIN_LUMINANCE
	canvas_modulate.color.s = sun_intensity * SATURATION_RANGE + MIN_SATURATION
	time_passed += delta
	
	var day_time = START_TIME_SECONDS + day_progress * (END_TIME_SECONDS - START_TIME_SECONDS)
	var day_hours = floor(day_time / 3600)
	var day_minutes = floor((day_time - day_hours * 3600) / 60)
	if previous_day_time == null or (day_time - previous_day_time) >= TIME_LABEL_UPDATE_PERIOD_MINUTES * 60:
		$HUD/TimeLabel.text = "%02d:%02d" % [day_hours, day_minutes]
		previous_day_time = day_time
	
	if is_equal_approx(day_progress, 1):
		day_changed.emit()

func _pause():
	$HUD/PauseMenu.show()

func _game_over():
	$HUD/GameOver.show()
