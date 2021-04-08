tool
extends MarginContainer


const VariableType = preload("../resources/VariableSetNode.gd").VariableType


signal value_changed()


onready var LineEdit = get_node("LineEdit")
onready var SpinBox = get_node("SpinBox")
onready var CheckBox = get_node("CheckBox")


var _variable_type = VariableType.TYPE_BOOL


func _ready():
	_configure_for_type()


func set_variable_type(t):
	_variable_type = t
	_configure_for_type()


func _configure_for_type():
	LineEdit.visible = _variable_type == VariableType.TYPE_STRING
	SpinBox.visible = _variable_type == VariableType.TYPE_INT or _variable_type == VariableType.TYPE_REAL
	CheckBox.visible = _variable_type == VariableType.TYPE_BOOL
	if _variable_type == VariableType.TYPE_INT or _variable_type == VariableType.TYPE_REAL:
		SpinBox.rounded = (_variable_type == VariableType.TYPE_INT)
		if _variable_type == VariableType.TYPE_INT:
			SpinBox.step = 1
			SpinBox.value = SpinBox.value as int
		else:
			SpinBox.step = 0


func set_value(val):
	match _variable_type:
		VariableType.TYPE_BOOL:
			if val == null:
				CheckBox.pressed = true
			else:
				CheckBox.pressed = val
		VariableType.TYPE_STRING:
			if val == null:
				LineEdit.text = ""
			else:
				LineEdit.text = val
		VariableType.TYPE_INT, VariableType.TYPE_REAL:
			if val == null:
				SpinBox.value = 0
			else:
				SpinBox.value = val


func get_value():
	match _variable_type:
		VariableType.TYPE_BOOL:
			return CheckBox.pressed
		VariableType.TYPE_STRING:
			return LineEdit.text
		VariableType.TYPE_INT:
			print(SpinBox.value as int)
			return SpinBox.value as int
		VariableType.TYPE_REAL:
			print(SpinBox.value as float)
			return SpinBox.value as float


func _on_CheckBox_pressed():
	emit_signal("value_changed")


func _on_SpinBox_value_changed(value):
	emit_signal("value_changed")


func _on_LineEdit_text_changed(new_text):
	emit_signal("value_changed")


func _on_SpinBox_changed():
	emit_signal("value_changed")
