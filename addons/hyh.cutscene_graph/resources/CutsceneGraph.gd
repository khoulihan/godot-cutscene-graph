tool
extends Resource

export (String) var name
export (String) var display_name
export (String) var graph_type
export (bool) var split_dialogue = true
export (Dictionary) var nodes
export (Resource) var root_node
export (Array, Resource) var characters
export (String, MULTILINE) var notes


func get_next_id():
	var id = 1
	var existing = nodes.keys()
	while true:
		if !(id in existing):
			return id
		id += 1
		


func _init():
	self.nodes = {}
	self.characters = []
