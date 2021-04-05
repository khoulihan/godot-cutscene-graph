tool
extends MarginContainer


signal remove_requested()
signal modified()


onready var VariableEdit = get_node("VBoxContainer/HBoxContainer/VariableContainer/VariableEdit")
onready var ValueEdit = get_node("VBoxContainer/HBoxContainer/VariableContainer/ValueEdit")
onready var ScopeSelect = get_node("VBoxContainer/HBoxContainer/VariableContainer/ScopeSelect")


func get_variable():
	return VariableEdit.text


func get_value():
	return ValueEdit.text


func get_scope():
	return ScopeSelect.selected


func set_random(variable, scope, value):
	VariableEdit.text = variable
	ValueEdit.text = value
	ScopeSelect.select(scope)


func _on_RemoveButton_pressed():
	emit_signal("remove_requested")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ValueEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ScopeSelect_item_selected(index):
	emit_signal("modified")
