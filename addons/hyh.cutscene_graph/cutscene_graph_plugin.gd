tool
extends EditorPlugin

var editor

func _enter_tree():
	add_custom_type("CutsceneGraph", "Resource", preload("resources/CutsceneGraph.gd"), preload("icon_graph_node.svg"))
	add_custom_type("Character", "Resource", preload("resources/Character.gd"), preload("icon_sprite.svg"))
	add_custom_type("CharacterVariant", "Resource", preload("resources/CharacterVariant.gd"), preload("icon_texture_rect.svg"))
	# TODO: Need a new icon for this - should be white at the very least, like other Node-derived types
	add_custom_type("CutsceneController", "Node", preload("scripts/CutsceneController.gd"), preload("icon_graph_node.svg"))
	self.connect("main_screen_changed", self, "_main_screen_changed")
	
	editor = preload("scenes/CutsceneGraphEditor.tscn").instance()
	editor.connect("save_requested", self, "_save_requested")


func _save_requested(object, path):
	ResourceSaver.save(path, object)
	ResourceLoader.load(path)

func _exit_tree():
	remove_custom_type("CutsceneGraph")
	remove_custom_type("Character")
	remove_custom_type("CharacterVariant")
	remove_custom_type("CutsceneController")
	get_editor_interface().get_editor_viewport().remove_child(editor)
	if editor != null:
		editor.free()

func _main_screen_changed(screen_name):
	if screen_name == get_plugin_name():
		_add_screen()
	else:
		_remove_screen()

func _add_screen():
	get_editor_interface().get_editor_viewport().add_child(editor)

func _remove_screen():
	get_editor_interface().get_editor_viewport().remove_child(editor)

func has_main_screen():
	return true

func get_plugin_name():
	return "Dialogue Graph"

func get_plugin_icon():
	return preload("icon_graph_edit.svg")

func handles(object):
	return (object is preload("resources/CutsceneGraph.gd"))

func make_visible(visible):
	pass

func edit(object):
	var current_resource_path = object.resource_path
	call_deferred("_request_edit", object, current_resource_path)

func _request_edit(object, current_resource_path):
	editor.edit_graph(object, current_resource_path)
