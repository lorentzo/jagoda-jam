extends Node2D

const MAIN_MENU_SCENE = "res://Scenes/MainMenu.tscn"
const DAY_LENGTH_MINUTES: int = 7
const DAY_LENGTH_SECONDS: int = DAY_LENGTH_MINUTES * 60
const MIN_LUMINANCE: float = 0.3
const MAX_LUMINANCE: float = 1.0
const LUMINANCE_RANGE: float = MAX_LUMINANCE - MIN_LUMINANCE
const GAME_DAYS: int = 7

@onready var loading = get_node("/root/Loading")
@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var sun: Sprite2D = $HUD/Sun
@onready var screen_width = get_viewport().size.x

var day = 0
var time_passed = 0

signal sun_intensity_changed(sun_intensity)
signal day_changed

func _ready():
	sun_intensity_changed.connect($Player.on_sun_intensity_changed)
	$Player.player_freshness_changed.connect(self._on_player_freshness_changed)
	
	day_changed.connect(self._on_day_changed)
	
	for plant in get_tree().get_nodes_in_group("plant"):
		sun_intensity_changed.connect(plant.on_sun_intensity_changed)
		day_changed.connect(plant.on_day_changed)

	day_changed.emit()
	loading.on_loading_start.connect(self._on_loading_start)

func _on_loading_start():
	$Player/Camera2D.queue_free()
	$HUD.hide()
	$ThemePlayer.stop()
	self.hide()

func _on_player_freshness_changed(freshness):
	$HUD/PlayerFreshnessBar.value = freshness

func _on_day_changed():
	self.day += 1
	$HUD/DayLabel.text = "Day {0} / {1}".format([day, GAME_DAYS])

func _input(event):
	if event.is_action_pressed("pause"):
		self._pause()

func _process(delta):
	var day_progress: float = min(time_passed / DAY_LENGTH_SECONDS, 1)
	var sun_intensity: float = sin(day_progress * PI)
	sun_intensity_changed.emit(sun_intensity)
	
	sun.position.x = day_progress * screen_width
	canvas_modulate.color.v = sun_intensity * LUMINANCE_RANGE + MIN_LUMINANCE
	time_passed += delta
	
	if is_equal_approx(day_progress, 1):
		self.hide()
		loading.load_scene(MAIN_MENU_SCENE)

func _pause():
	$HUD/PauseMenu.show()
