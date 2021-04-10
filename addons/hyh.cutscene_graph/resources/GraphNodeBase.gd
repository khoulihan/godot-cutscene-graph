tool
extends Resource


export (int) var id
# The node to move to next. This may be a default fallback for some node types.
export (int) var next
# Specifically for display in custom graph editor
export(Vector2) var offset


func _init():
	pass
