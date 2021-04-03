tool
extends Resource

export (String) var name
export (String) var display_name
export (String) var graph_type
export (Array) var nodes
export (Resource) var root_node
export (Array, Resource) var characters
export (String, MULTILINE) var notes

func _init():
	self.nodes = []
	self.characters = []
