tool
extends MarginContainer


signal remove_requested()
signal modified()


onready var VariableEdit = get_node("VBoxContainer/HBoxContainer/VariableContainer/VariableEdit")
onready var ValueEdit = get_node("VBoxContainer/HBoxContainer/VariableContainer/ValueEdit")
onready var ScopeSelect = get_node("VBoxContainer/HBoxContainer/VariableContainer/ScopeSelect")
onready var TypeSelect = get_node("VBoxContainer/HBoxContainer/VariableContainer/TypeSelect")


func get_variable():
	return VariableEdit.text


func get_type():
	return TypeSelect.get_selected_id()


func get_value():
	return ValueEdit.get_value()


func get_scope():
	return ScopeSelect.selected


func set_random(variable, variable_type, scope, value):
	TypeSelect.select(TypeSelect.get_item_index(variable_type))
	VariableEdit.text = variable
	ValueEdit.set_variable_type(variable_type)
	ValueEdit.set_value(value)
	ScopeSelect.select(scope)


func _on_RemoveButton_pressed():
	emit_signal("remove_requested")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ScopeSelect_item_selected(index):
	emit_signal("modified")


func _on_ValueEdit_value_changed():
	emit_signal("modified")


func _on_TypeSelect_item_selected(index):
	ValueEdit.set_variable_type(TypeSelect.get_item_id(index))
	emit_signal("modified")
