# Holds a scene, and offers some utilities to play it, pause it,
# and replace scripts on running nodes
extends ViewportContainer

const SceneFiles := preload("../collections/SceneFiles.gd")
const ScriptHandler := preload("../collections/ScriptHandler.gd")
const ScriptSlice := preload("../collections/ScriptSlice.gd")

var _viewport := Viewport.new()
var scene_paused := false setget set_scene_paused


func _init() -> void:
	_viewport.name = "Viewport"
	add_child(_viewport)


func _ready() -> void:
	get_tree().connect("screen_resized", self, "_on_screen_resized")
	get_tree().call_deferred("emit_signal", "screen_resized")


# Recursively pauses a node and its children
static func pause_node(node: Node, pause := true, limit := 1000) -> void:
	node.set_process(not pause)
	node.set_physics_process(not pause)
	node.set_process_input(not pause)
	node.set_process_internal(not pause)
	node.set_process_unhandled_input(not pause)
	node.set_process_unhandled_key_input(not pause)
	if limit > 0:
		limit -= 1
		for child in node.get_children():
			pause_node(child, pause, limit)


# Pauses the current GameViewport scene
func pause_scene(pause := true, limit := 1000) -> void:
	scene_paused = pause
	pause_node(LiveEditorState.current_scene, pause, limit)


# Toggles a scene's paused state on and off
func toggle_scene_pause() -> void:
	pause_scene(not scene_paused)


func set_scene_paused(is_it: bool) -> void:
	pause_scene(is_it)


func _on_screen_resized() -> void:
	_viewport.size = rect_size


func use_scene() -> void:
	LiveEditorState.use_scene(_viewport)
	_viewport.size = LiveEditorState.current_slice.get_scene_properties().viewport_size
	# _on_screen_resized
