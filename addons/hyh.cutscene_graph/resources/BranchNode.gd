tool
extends "GraphNodeBase.gd"

const VariableScope = preload("VariableSetNode.gd").VariableScope

export (String) var variable
export (VariableScope) var scope
export (Array, String) var values
export (Array, Resource) var branches

func _init():
	pass
