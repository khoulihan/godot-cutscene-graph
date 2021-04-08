tool
extends MarginContainer


onready var DisplayEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/DisplayEdit")
onready var TranslationKeyEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/TranslationKeyEdit")
onready var VariableEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/VariableEdit")
onready var ScopeSelect = get_node("HBoxContainer/VariableContainer/DisplayContainer/ScopeSelect")
onready var ValueEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/ValueEdit")
onready var TypeSelect = get_node("HBoxContainer/VariableContainer/DisplayContainer/TypeSelect")


signal remove_requested()
signal modified()


func get_variable():
	return VariableEdit.text


func get_type():
	return TypeSelect.get_selected_id()


func get_value():
	return ValueEdit.get_value()


func get_display_text():
	return DisplayEdit.text


func get_translation_key_text():
	return TranslationKeyEdit.text


func get_scope():
	return ScopeSelect.selected


func set_choice(variable, variable_type, scope, value, display, translation_key):
	TypeSelect.select(TypeSelect.get_item_index(variable_type))
	VariableEdit.text = variable
	ValueEdit.set_variable_type(variable_type)
	ValueEdit.set_value(value)
	DisplayEdit.text = display
	TranslationKeyEdit.text = translation_key
	ScopeSelect.select(scope)


func _on_RemoveButton_pressed():
	emit_signal("remove_requested")


func _on_DisplayEdit_text_changed(new_text):
	emit_signal("modified")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_TranslationKeyEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ScopeSelect_item_selected(index):
	emit_signal("modified")


func _on_TypeSelect_item_selected(index):
	ValueEdit.set_variable_type(TypeSelect.get_item_id(index))
	emit_signal("modified")


func _on_ValueEdit_value_changed():
	emit_signal("modified")
