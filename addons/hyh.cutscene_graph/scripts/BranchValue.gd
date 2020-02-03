tool
extends MarginContainer

signal remove_requested()
signal modified()

export (bool) var locked = false
export (String) var value

func _ready():
	set_locked(locked)
	set_value(value)

func set_locked(val):
	$HorizontalLayout/ValueEdit.editable = !val
	$HorizontalLayout/RemoveButton.visible = !val

func set_value(val):
	if val != null:
		$HorizontalLayout/ValueEdit.text = val

func get_value():
	return $HorizontalLayout/ValueEdit.text

func _on_RemoveButton_pressed():
	emit_signal("remove_requested")


func _on_ValueEdit_text_changed(new_text):
	emit_signal("modified")
