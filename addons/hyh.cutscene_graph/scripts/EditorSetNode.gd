tool
extends "EditorGraphNodeBase.gd"


onready var VariableEdit = get_node("MarginContainer/GridContainer/VariableEdit")
onready var ValueEdit = get_node("MarginContainer/GridContainer/ValueEdit")
onready var ScopeSelect = get_node("MarginContainer/GridContainer/ScopeSelect")
onready var TypeSelect = get_node("MarginContainer/GridContainer/TypeSelect")


func configure_for_node(n):
	.configure_for_node(n)
	set_variable(n.variable)
	set_type(n.variable_type)
	set_value(n.get_value())
	set_scope(n.scope)


func persist_changes_to_node():
	.persist_changes_to_node()
	node_resource.variable = get_variable()
	node_resource.variable_type = get_type()
	node_resource.set_value(get_value())
	node_resource.scope = get_scope()


func get_variable():
	return VariableEdit.text


func set_variable(val):
	VariableEdit.text = val


func get_value():
	return ValueEdit.get_value()


func set_value(val):
	ValueEdit.set_value(val)


func get_scope():
	return ScopeSelect.get_selected_id()


func set_scope(val):
	ScopeSelect.select(val)


func get_type():
	return TypeSelect.get_selected_id()


func set_type(val):
	TypeSelect.select(TypeSelect.get_item_index(val))
	ValueEdit.set_variable_type(val)


func _on_gui_input(ev):
	._on_gui_input(ev)


func _on_ScopeSelect_item_selected(ID):
	emit_signal("modified")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ValueEdit_value_changed():
	emit_signal("modified")


func _on_TypeSelect_item_selected(index):
	ValueEdit.set_variable_type(TypeSelect.get_item_id(index))
	emit_signal("modified")
