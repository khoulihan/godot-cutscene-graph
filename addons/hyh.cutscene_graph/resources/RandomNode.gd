tool
extends "GraphNodeBase.gd"

const VariableScope = preload("VariableSetNode.gd").VariableScope

export (Array, String) var variables
export (Array, VariableScope) var scopes
export (Array, String) var values
export (Array, Resource) var branches

func _init():
	pass
