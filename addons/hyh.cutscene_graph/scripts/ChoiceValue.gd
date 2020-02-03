tool
extends MarginContainer

signal remove_requested()
signal modified()

func get_variable():
	return $VerticalLayout/VariableContainer/VariableEdit.text

func get_value():
	return $VerticalLayout/VariableContainer/ValueEdit.text

func get_display_text():
	return $VerticalLayout/DisplayContainer/DisplayEdit.text

func get_translation_key_text():
	return $VerticalLayout/DisplayContainer/TranslationKeyEdit.text

func set_choice(variable, value, display, translation_key):
	$VerticalLayout/VariableContainer/VariableEdit.text = variable
	$VerticalLayout/VariableContainer/ValueEdit.text = value
	$VerticalLayout/DisplayContainer/DisplayEdit.text = display
	$VerticalLayout/DisplayContainer/TranslationKeyEdit.text = translation_key

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
