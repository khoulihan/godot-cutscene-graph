tool
extends "EditorGraphNodeBase.gd"


func configure_for_node(n):
	.configure_for_node(n)
	set_variable(n.variable)
	set_value(n.value)
	set_scope(n.scope)


func persist_changes_to_node():
	.persist_changes_to_node()
	node_resource.variable = get_variable()
	node_resource.value = get_value()
	node_resource.scope = get_scope()


func get_variable():
	return $MarginContainer/GridContainer/VariableEdit.text


func set_variable(val):
	$MarginContainer/GridContainer/VariableEdit.text = val


func get_value():
	return $MarginContainer/GridContainer/ValueEdit.text


func set_value(val):
	$MarginContainer/GridContainer/ValueEdit.text = val


func get_scope():
	return $MarginContainer/GridContainer/ScopeSelect.selected


func set_scope(val):
	$MarginContainer/GridContainer/ScopeSelect.select(val)


func _on_gui_input(ev):
	._on_gui_input(ev)


func _on_ScopeSelect_item_selected(ID):
	emit_signal("modified")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ValueEdit_text_changed(new_text):
	emit_signal("modified")
