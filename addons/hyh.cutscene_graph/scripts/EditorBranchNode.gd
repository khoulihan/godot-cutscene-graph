tool
extends "EditorGraphNodeBase.gd"

var _branch_value_scene = preload("../scenes/BranchValue.tscn")

const VariableScope = preload("../resources/VariableSetNode.gd").VariableScope
const VariableType = preload("../resources/VariableSetNode.gd").VariableType


onready var VariableEdit = get_node("MarginContainer/VBoxContainer/HeaderContainer/GridContainer/VariableEdit")
onready var ScopeSelect = get_node("MarginContainer/VBoxContainer/HeaderContainer/GridContainer/ScopeSelect")
onready var TypeSelect = get_node("MarginContainer/VBoxContainer/HeaderContainer/GridContainer/TypeSelect")


func get_variable():
	return VariableEdit.text


func set_variable(val):
	if val != null:
		VariableEdit.text = val
	else:
		VariableEdit.text = ""


func get_values():
	var values = []
	for index in range(1, get_child_count()):
		values.append(get_child(index).get_value())
	return values


func set_values(values):
	clear_branches()
	for index in range(0, values.size()):
		_add_branch(values[index])


func get_scope():
	return ScopeSelect.selected


func set_scope(val):
	if val != null:
		ScopeSelect.select(val)
	else:
		ScopeSelect.select(ScopeSelect.get_item_index(VariableScope.SCOPE_DIALOGUE))


func get_type():
	return TypeSelect.get_selected_id()


func set_type(val):
	if val != null:
		TypeSelect.select(TypeSelect.get_item_index(val))
	else:
		TypeSelect.select(TypeSelect.get_item_index(VariableType.TYPE_BOOL))
	for index in range(1, get_child_count()):
		get_child(index).set_type(val)


func _add_branch(value):
	var line = _create_branch()
	line.set_value(value)


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
	var new_value_line = _branch_value_scene.instance()
	add_child(new_value_line)
	new_value_line.set_type(node_resource.variable_type)
	new_value_line.connect("remove_requested", self, "_value_remove_requested", [get_child_count() - 1])
	new_value_line.connect("modified", self, "_value_modified", [get_child_count() - 1])
	set_slot(get_child_count() - 1, false, 0, Color("#cff44c"), true, 0, Color("#cff44c"))
	return new_value_line


func configure_for_node(n):
	.configure_for_node(n)
	set_variable(n.variable)
	set_scope(n.scope)
	set_type(n.variable_type)
	set_values(n.get_values())


func persist_changes_to_node():
	.persist_changes_to_node()
	node_resource.variable = get_variable()
	node_resource.scope = get_scope()
	node_resource.variable_type = get_type()
	var values = get_values()
	node_resource.branch_count = len(values)
	node_resource.set_values(values)


func clear_node_relationships():
	.clear_node_relationships()
	node_resource.branches = []
	var values = node_resource.get_values()
	for index in range(0, values.size()):
		node_resource.branches.append(null)


func _on_AddValueButton_pressed():
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


func _on_ScopeSelect_item_selected(index):
	emit_signal("modified")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_TypeSelect_item_selected(index):
	for i in range(1, get_child_count()):
		get_child(i).set_type(TypeSelect.get_item_id(index))
	emit_signal("modified")
