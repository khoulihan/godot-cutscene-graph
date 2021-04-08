tool
extends "EditorGraphNodeBase.gd"

var _choice_value_scene = preload("../scenes/ChoiceValue.tscn")


func get_variables():
	var variables = []
	for index in range(1, get_child_count()):
		variables.append(get_child(index).get_variable())
	return variables


func get_types():
	var var_types = []
	for index in range(1, get_child_count()):
		var_types.append(get_child(index).get_type())
	return var_types


func get_values():
	var values = []
	for index in range(1, get_child_count()):
		values.append(get_child(index).get_value())
	return values


func get_display_texts():
	var displays = []
	for index in range(1, get_child_count()):
		displays.append(get_child(index).get_display_text())
	return displays


func get_translation_keys():
	var keys = []
	for index in range(1, get_child_count()):
		keys.append(get_child(index).get_translation_key_text())
	return keys


func get_scopes():
	var scopes = []
	for index in range(1, get_child_count()):
		scopes.append(get_child(index).get_scope())
	return scopes


func clear_choices():
	for index in range(get_child_count() - 1, 0, -1):
		remove_choice(index)


func remove_choice(index):
	emit_signal("removing_slot", index)
	var node = get_child(index)
	remove_child(node)
	node.disconnect("remove_requested", self, "_value_remove_requested")
	reconnect_removal_signals()


func set_choices(
	variables,
	variable_types,
	scopes,
	values,
	display_texts,
	translation_keys
):
	clear_choices()
	for index in range(0, display_texts.size()):
		_add_choice(
			variables[index],
			variable_types[index],
			scopes[index],
			values[index],
			display_texts[index],
			translation_keys[index]
		)


func _add_choice(
	variable,
	variable_type,
	scope,
	value,
	display,
	translation_key
):
	var line = _create_line()
	line.set_choice(
		variable,
		variable_type,
		scope,
		value,
		display,
		translation_key
	)


func _create_line():
	var new_value_line = _choice_value_scene.instance()
	add_child(new_value_line)
	new_value_line.connect("remove_requested", self, "_value_remove_requested", [get_child_count() - 1])
	new_value_line.connect("modified", self, "_line_modified", [get_child_count() - 1])
	set_slot(get_child_count() - 1, false, 0, Color("#cff44c"), true, 0, Color("#cff44c"))
	return new_value_line


func configure_for_node(n):
	.configure_for_node(n)
	set_choices(
		n.variables,
		n.variable_types,
		n.scopes,
		n.get_values(),
		n.display,
		n.display_translation_keys
	)


func persist_changes_to_node():
	.persist_changes_to_node()
	node_resource.variables = get_variables()
	node_resource.variable_types = get_types()
	node_resource.set_values(get_values())
	node_resource.display = get_display_texts()
	node_resource.display_translation_keys = get_translation_keys()
	node_resource.scopes = get_scopes()


func clear_node_relationships():
	.clear_node_relationships()
	node_resource.branches = []
	for index in range(0, node_resource.variables.size()):
		node_resource.branches.append(null)


func _on_AddValueButton_pressed():
	_create_line()
	emit_signal("modified")


func _value_remove_requested(index):
	remove_choice(index)
	emit_signal("modified")


func _line_modified(index):
	emit_signal("modified")


func reconnect_removal_signals():
	if get_child_count() > 1:
		for index in range(1, get_child_count()):
			get_child(index).disconnect("remove_requested", self, "_value_remove_requested")
			get_child(index).connect("remove_requested", self, "_value_remove_requested", [index])


func _on_gui_input(ev):
	._on_gui_input(ev)
