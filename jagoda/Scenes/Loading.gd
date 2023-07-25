extends Control

@export var min_loading_time: float = 0.5

@onready var tree = get_tree()

signal on_loading_start

var path = null
var loading_time = 0

func _ready():
	self._stop()

func _process(delta):
	if self.path == null:
		return
		
	if loading_time >= min_loading_time:
		var status = ResourceLoader.load_threaded_get_status(self.path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(self.path)
			tree.change_scene_to_packed(scene)
			self._stop()
		elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or status == ResourceLoader.THREAD_LOAD_FAILED:
			print("Loading %s failed." % self.path)
			tree.quit(1)
	
	self.loading_time += delta

func _stop():
	self.path = null
	self.hide()
	set_process(false)

func load_scene(path):
	self.loading_time = 0
	self.path = path
	ResourceLoader.load_threaded_request(self.path)
	
	self.on_loading_start.emit()
	
	self.show()
	set_process(true)
