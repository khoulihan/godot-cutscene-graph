extends Node

class_name Cutscene

signal cutscene_triggered(cutscene)

export(Resource) var cutscene

var _cutscene_controller

func _ready():
	# Need to find the CutsceneController - there should only be one
	# Do this by walking the tree from the root. This should find it whether
	# it is an autoload or part of the scene.
	var root = get_tree().root
	_cutscene_controller = _find_controller(root)

func _find_controller(root):
	if root is CutsceneController:
		return root
	# Breadth-first search on the assumption that the controller
	# will be close to the root rather than deeply nested.
	for child in root.get_children():
		if child is CutsceneController:
			return child
	for child in root.get_children():
		var result = _find_controller(child)
		if result != null:
			return result
	return null

func trigger():
	emit_signal("cutscene_triggered", self.cutscene)
	if _cutscene_controller != null:
		_cutscene_controller.process_cutscene(cutscene)
