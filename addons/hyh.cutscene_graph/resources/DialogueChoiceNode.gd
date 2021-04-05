tool
extends "GraphNodeBase.gd"

const VariableScope = preload("VariableSetNode.gd").VariableScope

export (Array, String) var variables
export (Array, VariableScope) var scopes
export (Array, String) var values
export (Array, String) var display
export (Array, String) var display_translation_keys
export (Array, Resource) var branches

func _init():
	pass
