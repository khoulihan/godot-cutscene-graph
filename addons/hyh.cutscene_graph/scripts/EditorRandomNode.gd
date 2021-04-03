tool
extends "EditorGraphNodeBase.gd"

var _random_value_scene = preload("../scenes/RandomValue.tscn")


func get_variables():
	var variables = []
	for index in range(1, get_child_count()):
		variables.append(get_child(index).get_variable())
	return variables


func get_values():
	var values = []
	for index in range(1, get_child_count()):
		values.append(get_child(index).get_value())
	return values


func set_branches(variables, values):
	clear_branches()
	for index in range(0, values.size()):
		_add_branch(variables[index], values[index])


func _add_branch(variable, value):
	var line = _create_branch()
	line.set_random(variable, value)


func clear_branches():
	for index in range(get_child_count() - 1, 0, -1):
		remove_branch(index)


func remove_branch(index):
	emit_signal("removing_slot", index)
	var node = get_child(index)
	remove_child(node)
	node.disconnect("remove_requested", self, "_value_remove_requested")
	node.disconnect("modified", self, "_value_modified")
	reconnect_signals()


func _create_branch():
	var new_value_line = _random_value_scene.instance()
	add_child(new_value_line)
	new_value_line.connect("remove_requested", self, "_value_remove_requested", [get_child_count() - 1])
	new_value_line.connect("modified", self, "_value_modified", [get_child_count() - 1])
	set_slot(get_child_count() - 1, false, 0, Color("#cff44c"), true, 0, Color("#cff44c"))
	return new_value_line


func configure_for_node(n):
	.configure_for_node(n)
	set_branches(n.variables, n.values)


func persist_changes_to_node():
	.persist_changes_to_node()
	node_resource.variables = get_variables()
	node_resource.values = get_values()


func clear_node_relationships():
	.clear_node_relationships()
	node_resource.branches = []
	for index in range(0, node_resource.values.size()):
		node_resource.branches.append(null)


func _on_AddBranchButton_pressed():
	var new_value_line = _create_branch()
	emit_signal("modified")


func _value_remove_requested(index):
	remove_branch(index)


func _value_modified(index):
	emit_signal("modified")


func reconnect_signals():
	if get_child_count() > 1:
		for index in range(1, get_child_count()):
			get_child(index).disconnect("remove_requested", self, "_value_remove_requested")
			get_child(index).disconnect("modified", self, "_value_modified")
			get_child(index).connect("remove_requested", self, "_value_remove_requested", [index])
			get_child(index).connect("modified", self, "_value_modified", [index])


func _on_gui_input(ev):
	._on_gui_input(ev)

