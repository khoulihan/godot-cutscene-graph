tool
extends "GraphNodeBase.gd"


const VariableScope = preload("VariableSetNode.gd").VariableScope
const VariableType = preload("VariableSetNode.gd").VariableType


export (String) var variable
export (VariableType) var variable_type = VariableType.TYPE_BOOL
export (VariableScope) var scope
export (int) var branch_count = 0
export (Array, int) var branches
export (Array, bool) var bool_values
export (Array, int) var int_values
export (Array, float) var float_values
export (Array, String) var string_values


func get_value(index):
	match variable_type:
		VariableType.TYPE_BOOL:
			return bool_values[index]
		VariableType.TYPE_INT:
			return int_values[index]
		VariableType.TYPE_REAL:
			return float_values[index]
		VariableType.TYPE_STRING:
			return string_values[index]


func get_values():
	var values = []
	for i in range(branch_count):
		match variable_type:
			VariableType.TYPE_BOOL:
				values.append(bool_values[i])
			VariableType.TYPE_INT:
				values.append(int_values[i])
			VariableType.TYPE_REAL:
				values.append(float_values[i])
			VariableType.TYPE_STRING:
				values.append(string_values[i])
	return values


func set_values(values):
	bool_values.resize(branch_count)
	int_values.resize(branch_count)
	float_values.resize(branch_count)
	string_values.resize(branch_count)
	for i in range(branch_count):
		match variable_type:
			VariableType.TYPE_BOOL:
				bool_values[i] = values[i]
			VariableType.TYPE_INT:
				int_values[i] = values[i]
			VariableType.TYPE_REAL:
				float_values[i] = values[i]
			VariableType.TYPE_STRING:
				string_values[i] = values[i]


func _init():
	pass
