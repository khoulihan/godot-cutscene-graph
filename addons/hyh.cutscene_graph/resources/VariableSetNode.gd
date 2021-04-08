tool
extends "GraphNodeBase.gd"

enum VariableScope {
	SCOPE_DIALOGUE,
	SCOPE_SCENE,
	SCOPE_GLOBAL
}

# These match the Variant.Type enum... which I could not reference directly
# for some reason. Anyway we only need a few of them.
enum VariableType {
	TYPE_BOOL = 1,
	TYPE_INT = 2,
	TYPE_REAL = 3,
	TYPE_STRING = 4
}

export (VariableScope) var scope
export (String) var variable
export (VariableType) var variable_type 
export (bool) var bool_value
export (int) var int_value
export (float) var float_value
export (String) var string_value


func get_value():
	match variable_type:
		VariableType.TYPE_BOOL:
			return bool_value
		VariableType.TYPE_INT:
			return int_value
		VariableType.TYPE_REAL:
			return float_value
		VariableType.TYPE_STRING:
			return string_value


func set_value(val):
	match variable_type:
		VariableType.TYPE_BOOL:
			bool_value = val
		VariableType.TYPE_INT:
			int_value = val
		VariableType.TYPE_REAL:
			float_value = val
		VariableType.TYPE_STRING:
			string_value = val


func _init():
	._init()
	if variable_type == null:
		variable_type = VariableType.TYPE_STRING
	elif variable_type == 0:
		variable_type = VariableType.TYPE_BOOL
	if "value" in self:
		if string_value == null or string_value == "":
			string_value = self.value
			
