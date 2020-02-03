tool
extends GraphNode

signal removing_slot(slot)
signal popup_request(p_position)
signal modified()

export (bool) var is_root setget set_root
export (Resource) var node_resource


func _ready():
	pass


func configure_for_node(n):
	"""
	Configure the editor node for a given graph node.
	"""
	node_resource = n
	offset = n.offset


func persist_changes_to_node():
	"""
	Persist changes from the editor node's controls into the graph node's properties
	"""
	node_resource.offset = offset


func clear_node_relationships():
	"""
	Clear the relationships of the underlying graph node.
	"""
	node_resource.next = null


func set_root(value):
	if value:
		self.overlay = GraphNode.OVERLAY_POSITION
	else:
		self.overlay = GraphNode.OVERLAY_DISABLED
	is_root = value


func _on_gui_input(ev):
	if ev is InputEventMouseButton:
		if ev.button_index == BUTTON_RIGHT and ev.pressed:
			accept_event()
			emit_signal("popup_request", ev.global_position)
