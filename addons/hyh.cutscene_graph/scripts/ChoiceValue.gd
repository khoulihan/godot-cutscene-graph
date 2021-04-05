tool
extends MarginContainer


onready var DisplayEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/DisplayEdit")
onready var TranslationKeyEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/TranslationKeyEdit")
onready var VariableEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/VariableEdit")
onready var ScopeSelect = get_node("HBoxContainer/VariableContainer/DisplayContainer/ScopeSelect")
onready var ValueEdit = get_node("HBoxContainer/VariableContainer/DisplayContainer/ValueEdit")


signal remove_requested()
signal modified()


func get_variable():
	return VariableEdit.text


func get_value():
	return ValueEdit.text


func get_display_text():
	return DisplayEdit.text


func get_translation_key_text():
	return TranslationKeyEdit.text


func get_scope():
	return ScopeSelect.selected


func set_choice(variable, scope, value, display, translation_key):
	VariableEdit.text = variable
	ValueEdit.text = value
	DisplayEdit.text = display
	TranslationKeyEdit.text = translation_key
	ScopeSelect.select(scope)


func _on_RemoveButton_pressed():
	emit_signal("remove_requested")


func _on_DisplayEdit_text_changed(new_text):
	emit_signal("modified")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ValueEdit_text_changed(new_text):
	emit_signal("modified")


func _on_TranslationKeyEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ScopeSelect_item_selected(index):
	emit_signal("modified")
