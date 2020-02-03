tool
extends "GraphNodeBase.gd"

enum VariableScope {
	SCOPE_DIALOGUE,
	SCOPE_SCENE,
	SCOPE_GLOBAL
}

export (VariableScope) var scope
export (String) var variable
export (String) var value

func _init():
	pass
