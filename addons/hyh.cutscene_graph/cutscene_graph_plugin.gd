tool
extends EditorPlugin

const CutsceneGraphEditor = preload("scenes/CutsceneGraphEditor.tscn")

var editor
var editor_button

func _enter_tree():
	add_custom_type("CutsceneGraph", "Resource", preload("resources/CutsceneGraph.gd"), preload("icon_graph_node.svg"))
	add_custom_type("Character", "Resource", preload("resources/Character.gd"), preload("icon_sprite.svg"))
	add_custom_type("CharacterVariant", "Resource", preload("resources/CharacterVariant.gd"), preload("icon_texture_rect.svg"))
	# TODO: Need a new icon for these - should be white at the very least, like other Node-derived types
	add_custom_type("CutsceneController", "Node", preload("scripts/CutsceneController.gd"), preload("icon_graph_node.svg"))
	add_custom_type("Cutscene", "Node", preload("scripts/Cutscene.gd"), preload("icon_graph_node.svg"))
	
	_create_editor()


func _create_editor():
	editor = preload("scenes/CutsceneGraphEditor.tscn").instance()
	editor.connect("save_requested", self, "_save_requested")
	editor_button = add_control_to_bottom_panel(editor, get_plugin_name())


# Not sure the cause of this issue, but the editor member is being cleared after
# the first time the project is run. The control is still present in Godot, but
# finding it again isn't enough because that has a bunch of references cleared as
# well. However, finding it and recreating it gets around the issue.
func _reacquire_editor():
	print ("Reacquiring graph editor")
	var root = get_editor_interface().get_base_control()
	var node_stack = [] + root.get_children()
	while !node_stack.empty():
		var current = node_stack.pop_back()
		if current.name == "CutsceneGraphEditor":
			editor = current
			node_stack.clear()
		else:
			node_stack = node_stack + current.get_children()
	if editor == null:
		print ("Editor not found")
	else:
		print ("Editor reacquired")
		remove_control_from_bottom_panel(editor)
		if editor != null:
			editor.free()
		_create_editor()


func apply_changes():
	if editor != null:
		editor.perform_save()


func clear():
	if editor != null:
		_request_clear()


func _save_requested(object, path):
	ResourceSaver.save(path, object)
	ResourceLoader.load(path)


func _exit_tree():
	remove_custom_type("CutsceneGraph")
	remove_custom_type("Character")
	remove_custom_type("CharacterVariant")
	remove_custom_type("CutsceneController")
	remove_custom_type("Cutscene")
	remove_control_from_bottom_panel(editor)
	if editor != null:
		editor.free()


func get_plugin_name():
	return "Cutscene Graph"


func get_plugin_icon():
	return preload("icon_graph_edit.svg")


func handles(object):
	return (object is preload("resources/CutsceneGraph.gd") or object is Cutscene)


func make_visible(visible):
	if visible:
		make_bottom_panel_item_visible(editor)


func edit(object):
	var graph
	if object is Cutscene:
		graph = object.cutscene
	else:
		graph = object
	if graph != null:
		var current_resource_path = graph.resource_path
		call_deferred("_request_edit", graph, current_resource_path)
	else:
		call_deferred("_request_clear")


func _request_edit(object, current_resource_path):
	if editor == null:
		_reacquire_editor()
	#if editor != null:
	editor.edit_graph(object, current_resource_path)


func _request_clear():
	editor.clear()
