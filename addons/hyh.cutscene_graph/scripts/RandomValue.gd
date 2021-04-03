tool
extends MarginContainer

signal remove_requested()
signal modified()

func get_variable():
	return $VariableContainer/VariableEdit.text

func get_value():
	return $VariableContainer/ValueEdit.text

func set_random(variable, value):
	$VariableContainer/VariableEdit.text = variable
	$VariableContainer/ValueEdit.text = value

func _on_RemoveButton_pressed():
	emit_signal("remove_requested")


func _on_VariableEdit_text_changed(new_text):
	emit_signal("modified")


func _on_ValueEdit_text_changed(new_text):
	emit_signal("modified")

