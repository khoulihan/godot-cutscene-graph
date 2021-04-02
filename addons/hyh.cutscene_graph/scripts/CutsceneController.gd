extends Node

# Walks a CutsceneGraph resource and raises signals with the details of each
# node.

signal cutscene_started()
signal cutscene_completed()
signal dialogue_display_requested(text, translation_key, character_name, character_variant)
signal action_requested(action, character_name, character_variant, argument)
signal variable_requested(variable_name, requester) # TODO: How to accept response? Coroutine? Reference to this node?
signal variable_set(variable_name, scope, value)

# Start walking the graph
func start():
	pass


# Indicates that the current node has been processed in full, and the controller
# should proceed to the next node.
# Dialogue and Action nodes suspend graph processing until told to proceed,
func proceed():
	pass


# Stop walking the graph prematurely.
func stop():
	pass


func _get_variable(variable_name):
	pass


func _set_variable(variable_name, scope, value):
	pass
