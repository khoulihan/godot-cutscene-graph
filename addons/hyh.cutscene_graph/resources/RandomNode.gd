tool
extends "GraphNodeBase.gd"

const VariableScope = preload("VariableSetNode.gd").VariableScope
const VariableType = preload("VariableSetNode.gd").VariableType

export (Array, String) var variables
export (Array, VariableScope) var scopes
export (Array, int) var branches
export (Array, VariableType) var variable_types
export (Array, bool) var bool_values
export (Array, int) var int_values
export (Array, float) var float_values
export (Array, String) var string_values


func get_value(index):
	match variable_types[index]:
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
	for i in range(len(branches)):
		match variable_types[i]:
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
	bool_values.resize(len(variable_types))
	int_values.resize(len(variable_types))
	float_values.resize(len(variable_types))
	string_values.resize(len(variable_types))
	for i in range(len(variable_types)):
		# TODO: Exception here after branch removal
		match variable_types[i]:
			VariableType.TYPE_BOOL:
				bool_values[i] = values[i]
			VariableType.TYPE_INT:
				int_values[i] = values[i]
			VariableType.TYPE_REAL:
				float_values[i] = values[i]
			VariableType.TYPE_STRING:
				string_values[i] = values[i]


func _init():
	print ("_init RandomNode")
	# This didn't work - I guess variable_types was actually an empty array?
	if variable_types == null:
		print("variable_types is null")
		variable_types = []
		for i in range(len(branches)):
			variable_types.append(VariableType.TYPE_STRING)
	# This didn't work - apparently removed properties are not present
	# for previously created nodes.
	if "values" in self:
		print("values property still present")
		if string_values == null:
			string_values = []
			for i in range(len(self.values)):
				string_values.add(self.values[i])
