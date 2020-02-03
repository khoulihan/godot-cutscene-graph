tool
extends "EditorGraphNodeBase.gd"

signal sub_graph_selection_requested()
signal sub_graph_open_requested(path)


func _get_sub_graph_path_edit():
	return get_node("MarginContainer/HBoxContainer/SubGraphPath")


func _get_remove_button():
	return get_node("MarginContainer/HBoxContainer/RemoveButton")


func _get_edit_button():
	return get_node("MarginContainer/HBoxContainer/EditButton")


func set_sub_graph_path(sub_graph):
	if sub_graph == null:
		_get_sub_graph_path_edit().text = ""
		_get_edit_button().disabled = true
		_get_remove_button().disabled = true
	else:
		_get_sub_graph_path_edit().text = sub_graph.resource_path
		_get_edit_button().disabled = false
		_get_remove_button().disabled = false


func configure_for_node(n):
	.configure_for_node(n)
	set_sub_graph_path(n.sub_graph)


func persist_changes_to_node():
	.persist_changes_to_node()
	# Selecting the resource should already persist it to the node


func _on_gui_input(ev):
	._on_gui_input(ev)


func _on_RemoveButton_pressed():
	node_resource.sub_graph = null
	set_sub_graph_path(node_resource.sub_graph)
	emit_signal("modified")


func _on_OpenButton_pressed():
	emit_signal("sub_graph_selection_requested")


func _on_EditButton_pressed():
	if node_resource.sub_graph != null:
		emit_signal("sub_graph_open_requested", node_resource.sub_graph)


func sub_graph_selected(sub_graph):
	node_resource.sub_graph = sub_graph
	set_sub_graph_path(sub_graph)
	emit_signal("modified")


func _on_SubGraphPath_gui_input(ev):
	if ev is InputEventMouseButton and node_resource.sub_graph != null:
		if ev.doubleclick:
			emit_signal("sub_graph_open_requested", node_resource.sub_graph)
