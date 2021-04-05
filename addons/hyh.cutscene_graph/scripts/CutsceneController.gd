extends Node

class_name CutsceneController

const CutsceneGraph = preload("../resources/CutsceneGraph.gd")
const DialogueTextNode = preload("../resources/DialogueTextNode.gd")
const BranchNode = preload("../resources/BranchNode.gd")
const DialogueChoiceNode = preload("../resources/DialogueChoiceNode.gd")
const VariableSetNode = preload("../resources/VariableSetNode.gd")
const ActionNode = preload("../resources/ActionNode.gd")
const SubGraph = preload("../resources/SubGraph.gd")
const RandomNode = preload("../resources/RandomNode.gd")

# Walks a CutsceneGraph resource and raises signals with the details of each
# node.

signal cutscene_started(cutscene_name, graph_type)
signal cutscene_completed()
signal dialogue_display_requested(
	text,
	character_name,
	character_variant,
	process
)
signal action_requested(
	action,
	character_name,
	character_variant,
	argument,
	process
)
signal choice_display_requested(choices, process)


export(NodePath) var global_store
export(NodePath) var scene_store
var _local_store : Dictionary
var _global_store : Node
var _scene_store : Node

var _graph
var _current_node


func register_global_store(store):
	_global_store = store


func register_scene_store(store):
	_scene_store = store


func _ready():
	if global_store != null:
		register_global_store(get_node(global_store))
	if scene_store != null:
		register_scene_store(get_node(scene_store))
	_local_store = {}


func _get_variable(variable_name, scope):
	match scope:
		VariableSetNode.VariableScope.SCOPE_DIALOGUE:
			# We can deal with these internally for the duration of a cutscene
			return _local_store[variable_name]
		VariableSetNode.VariableScope.SCOPE_SCENE:
			return _scene_store.get_variable(variable_name)
		VariableSetNode.VariableScope.SCOPE_GLOBAL:
			return _global_store.get_variable(variable_name)
	return null


func _get_first_variable(variable_name):
	if variable_name in _local_store:
		return _local_store[variable_name]
	if _scene_store.has_variable(variable_name):
		return _scene_store.get_variable(variable_name)
	if _global_store.has_variable(variable_name):
		return _global_store.get_variable(variable_name)
	return null


func _set_variable(variable_name, scope, value):
	match scope:
		VariableSetNode.VariableScope.SCOPE_DIALOGUE:
			# We can deal with these internally for the duration of a cutscene
			_local_store[variable_name] = value
		VariableSetNode.VariableScope.SCOPE_SCENE:
			_scene_store.set_variable(variable_name, value)
		VariableSetNode.VariableScope.SCOPE_GLOBAL:
			_global_store.set_variable(variable_name, value)


func _await_response():
	return yield()


func process_cutscene(cutscene):
	_local_store = {}
	_graph = cutscene
	_current_node = _graph.root_node
	emit_signal("cutscene_started", _graph.name, _graph.graph_type)
	while _current_node != null:
		print("Processing")
		if _current_node is DialogueTextNode:
			yield(_process_dialogue_node(), "completed")
		elif _current_node is BranchNode:
			_process_branch_node()
		elif _current_node is DialogueChoiceNode:
			var process_choices = _process_choice_node()
			if process_choices != null:
				yield(process_choices, "completed")
		elif _current_node is VariableSetNode:
			_process_set_node()
		elif _current_node is ActionNode:
			yield(_process_action_node(), "completed")
		elif _current_node is SubGraph:
			_process_subgraph_node()
		elif _current_node is RandomNode:
			_process_random_node()
	emit_signal("cutscene_completed")


func _emit_dialogue_signal(
	text,
	character_name,
	character_variant,
	process
):
	emit_signal(
		"dialogue_display_requested",
		text,
		character_name,
		character_variant,
		process
	)


func _process_dialogue_node():
	var text = null
	# Try the translation first
	var tr_key = _current_node.text_translation_key
	if tr_key != null and tr_key != "":
		text = tr(tr_key)
		if text == tr_key:
			text = null
	# Still no text, so use the default
	if text == null:
		text = _current_node.text
	
	# TODO: Make this splitting optional
	var lines = text.split("\n")
	for line in lines:
		# Just in case there are blank lines
		if line == "":
			continue
		var process = _await_response()
		call_deferred(
			"_emit_dialogue_signal",
			line,
			_current_node.character.character_name,
			_current_node.character_variant.variant_name,
			process
		)
		yield(process, "completed")
	_current_node = _current_node.next
	

func _process_branch_node():
	# Since branch nodes currently can't specify a scope, we just need to use
	# the "closest" matching variable
	var val = _get_first_variable(_current_node.variable)
	for i in range(len(_current_node.values)):
		if val == _current_node.values[i]:
			_current_node = _current_node.branches[i]
			return
	# Default case, no match or no branches
	_current_node = _current_node.next


func _emit_choices_signal(
	choices,
	process
):
	emit_signal(
		"choice_display_requested",
		choices,
		process
	)


func _process_choice_node():
	var choices = {}
	for i in range(len(_current_node.branches)):
		var valid = true
		var variable = _current_node.variables[i]
		if variable != null and variable != "":
			var val = _get_first_variable(variable)
			var expected_val = _current_node.values[i]
			valid = val == expected_val
		if valid:
			var text = null
			# Try the translation first
			var tr_key = _current_node.display_translation_keys[i]
			if tr_key != null and tr_key != "":
				text = tr(tr_key)
				if text == tr_key:
					text = null
			# Still no text, so use the default
			if text == null:
				text = _current_node.display[i]
			choices[i] = text
	if !choices.empty():
		print ("Choices: %s" % len(choices))
		var process = _await_response()
		call_deferred(
			"_emit_choices_signal",
			choices,
			process
		)
		var choice = yield(process, "completed")
		_current_node = _current_node.branches[choice]
	else:
		_current_node = _current_node.next


func _process_set_node():
	_set_variable(
		_current_node.variable,
		_current_node.scope,
		_current_node.value
	)
	_current_node = _current_node.next


func _emit_action_signal(
	action,
	character_name,
	character_variant,
	argument,
	process
):
	emit_signal(
		"action_requested",
		action,
		character_name,
		character_variant,
		argument,
		process
	)


func _process_action_node():
	var process = _await_response()
	# TODO: Possibility that character and variant may be optional, so risk of null refs here
	call_deferred(
		"_emit_action_signal",
		_current_node.action_name,
		_current_node.character.character_name,
		_current_node.character_variant.variant_name,
		_current_node.argument,
		process
	)
	yield(process, "completed")
	_current_node = _current_node.next


func _process_subgraph_node():
	# TODO: I think we need to create a "graph stack" to support subgraphs
	pass


func _process_random_node():
	var viable = []
	for i in range(len(_current_node.branches)):
		var variable = _current_node.variables[i]
		if variable == null or variable == "":
			viable.append(_current_node.branches[i])
		else:
			var val = _current_node.values[i]
			var stored = _get_first_variable(variable)
			if val == stored:
				viable.append(_current_node.branches[i])
	if len(viable) == 0:
		_current_node = _current_node.next
	else:
		_current_node = viable[randi() % len(viable)]
