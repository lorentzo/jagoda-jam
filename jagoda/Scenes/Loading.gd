extends Control

@onready var tree = get_tree()

var path = null

func _ready():
	self._stop()

func _process(delta):
	if self.path == null:
		return
		
	var status = ResourceLoader.load_threaded_get_status(self.path)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(self.path)
		tree.change_scene_to_packed(scene)
		self._stop()
	elif status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE or status == ResourceLoader.THREAD_LOAD_FAILED:
		print("Loading %s failed." % self.path)
		tree.quit(1)

func _stop():
	self.path = null
	self.hide()
	set_process(false)

func load_scene(path):
	self.path = path
	ResourceLoader.load_threaded_request(self.path)
	self.show()
	set_process(true)
