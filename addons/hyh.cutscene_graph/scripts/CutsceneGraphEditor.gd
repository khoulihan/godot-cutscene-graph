tool
extends VBoxContainer

signal save_requested(object, path)

const Character = preload("../resources/Character.gd")
const CharacterVariant = preload("../resources/CharacterVariant.gd")

const CutsceneGraph = preload("../resources/CutsceneGraph.gd")
const DialogueTextNode = preload("../resources/DialogueTextNode.gd")
const BranchNode = preload("../resources/BranchNode.gd")
const DialogueChoiceNode = preload("../resources/DialogueChoiceNode.gd")
const VariableSetNode = preload("../resources/VariableSetNode.gd")
const ActionNode = preload("../resources/ActionNode.gd")
const SubGraph = preload("../resources/SubGraph.gd")

const EditorTextNodeClass = preload("./EditorTextNode.gd")
const EditorBranchNodeClass = preload("./EditorBranchNode.gd")
const EditorChoiceNodeClass = preload("./EditorChoiceNode.gd")
const EditorSetNodeClass = preload("./EditorSetNode.gd")
const EditorGraphNodeBaseClass = preload("./EditorGraphNodeBase.gd")
const EditorActionNodeClass = preload("./EditorActionNode.gd")
const EditorSubGraphNodeClass = preload("./EditorSubGraphNode.gd")

const EditorTextNode = preload("../scenes/EditorTextNode.tscn")
const EditorBranchNode = preload("../scenes/EditorBranchNode.tscn")
const EditorChoiceNode = preload("../scenes/EditorChoiceNode.tscn")
const EditorSetNode = preload("../scenes/EditorSetNode.tscn")
const EditorGraphNodeBase = preload("../scenes/EditorGraphNodeBase.tscn")
const EditorActionNode = preload("../scenes/EditorActionNode.tscn")
const EditorSubGraphNode = preload("../scenes/EditorSubGraphNode.tscn")

class OpenGraph:
	var graph
	var path
	var dirty

	func get_filename():
		var name
		if path == null:
			name = "New Graph"
		else:
			name = path.get_file()
		if dirty:
			name += "(*)"
		return name

enum FileMenuItems {
	FILE_NEW = 0,
	FILE_OPEN = 1,
	FILE_SAVE = 3,
	FILE_SAVE_AS = 4,
	FILE_CLOSE = 6
}

enum GraphPopupMenuItems {
	ADD_TEXT_NODE,
	ADD_BRANCH_NODE,
	ADD_CHOICE_NODE,
	ADD_SET_NODE,
	ADD_ACTION_NODE,
	ADD_SUB_GRAPH_NODE
}

enum NodePopupMenuItems {
	SET_ROOT
}

enum ConfirmationActions {
	REMOVE_NODE,
	REMOVE_CHARACTER,
	CLOSE_GRAPH
}

var _open_graphs

var _edited

# Nodes
var _save_dialog
var _open_graph_dialog
var _open_sub_graph_dialog
var _open_character_dialog
onready var _graph_list = $EditorSplitter/SidebarSplitter/GraphList
onready var _graph_edit = $EditorSplitter/GraphEdit
onready var _graph_popup = $GraphContextMenu
onready var _node_popup = $NodePopupMenu
onready var _confirmation_dialog = $ConfirmationDialog
onready var _error_dialog = $ErrorDialog
onready var _character_list = $EditorSplitter/SidebarSplitter/CharacterListContainer/CharacterList

var _last_popup_position
var _confirmation_action
var _node_to_remove
var _node_for_popup
var _characters
var _character_to_remove
var _sub_graph_editor_node_for_assignment


func _init():
	_open_graphs = Array()
	_characters = []


func _ready():
	# Set up graph list
	_graph_list.connect("item_selected", self, "_graph_selection_changed")

	# Set up editor
	_graph_edit.connect("popup_request", self, "_graph_popup_requested")
	# TODO: Not sure how to achieve hiding the popup when the mouse is clicked elsewhere
	# The documentation suggests it should be automatic unless measures are taken, but
	# that does not seem to be the case
	#_graph_edit.connect("gui_input", self, "_graph_popup_dismissed")

	# Context menu
	_graph_popup.connect("index_pressed", self, "_graph_popup_index_pressed")
	_node_popup.connect("index_pressed", self, "_node_popup_index_pressed")

	# Confirmation dialog
	_confirmation_dialog.connect("confirmed", self, "_action_confirmed")

	_update_file_list()

	# Set up save dialog
	_save_dialog = EditorFileDialog.new()
	_save_dialog.add_filter("*.tres")
	_save_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_save_dialog.mode = EditorFileDialog.MODE_SAVE_FILE
	self.add_child(_save_dialog)
	_save_dialog.connect("file_selected", self, "_file_selected")

	# Set up Open dialogs
	_open_graph_dialog = EditorFileDialog.new()
	_open_graph_dialog.add_filter("*.tres")
	_open_graph_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_open_graph_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
	self.add_child(_open_graph_dialog)
	_open_graph_dialog.connect("file_selected", self, "_graph_file_selected_for_opening")

	_open_sub_graph_dialog = EditorFileDialog.new()
	_open_sub_graph_dialog.add_filter("*.tres")
	_open_sub_graph_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_open_sub_graph_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
	self.add_child(_open_sub_graph_dialog)
	_open_sub_graph_dialog.connect("file_selected", self, "_sub_graph_file_selected_for_opening")

	_open_character_dialog = EditorFileDialog.new()
	_open_character_dialog.add_filter("*.tres")
	_open_character_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	_open_character_dialog.mode = EditorFileDialog.MODE_OPEN_FILE
	self.add_child(_open_character_dialog)
	_open_character_dialog.connect("file_selected", self, "_character_file_selected_for_opening")

	# Set up file menu
	var fileMenuPopup = $MenuBar/FileMenuButton.get_popup()
	fileMenuPopup.connect("index_pressed", self, "_file_menu_index_pressed")


func edit_graph(object, path):
	_update_edited_graph()
	var edited
	print ("Attempting to edit path " + path)
	for graph in _open_graphs:
		if graph.path == path:
			edited = graph
			break
	if edited == null:
		edited = OpenGraph.new()
		edited.graph = object
		edited.path = path
		edited.dirty = false
		_open_graphs.append(edited)
	_edited = edited
	_draw_edited_graph()
	_update_file_list()


func _get_resource_path():
	_save_dialog.popup_centered_minsize(Vector2(800, 700))


func _get_open_path():
	_open_graph_dialog.popup_centered_minsize(Vector2(800, 700))


func _get_sub_graph_open_path():
	_open_sub_graph_dialog.popup_centered_minsize(Vector2(800, 700))


func _file_selected(path):
	_edited.path = path
	_perform_save()


func _graph_file_selected_for_opening(path):
	var res = load(path)
	if not res is CutsceneGraph:
		_error_dialog.dialog_text = "The selected resource is not a CutsceneGraph."
		_error_dialog.popup_centered()
		return
	edit_graph(res, path)


func _sub_graph_file_selected_for_opening(path):
	var res = load(path)
	if not res is CutsceneGraph:
		_error_dialog.dialog_text = "The selected resource is not a CutsceneGraph."
		_error_dialog.popup_centered()
		return
	_configure_sub_graph_node(_sub_graph_editor_node_for_assignment, res)


func _configure_sub_graph_node(editor_node, res):
	editor_node.sub_graph_selected(res)


func _character_file_selected_for_opening(path):
	var character = load(path)
	if not character is Character:
		_error_dialog.dialog_text = "The selected resource is not a Character."
		_error_dialog.popup_centered()
		return
	for existing in _characters:
		if existing == character:
			return
	_characters.append(character)
	_update_character_list(character)
	_set_dirty(true)


func _graph_popup_requested(p_position):
	if _edited:
		# TODO: Not sure how to get this position accurate - this offset I'm adding doesn't work at zoom levels other than 1:1
		_last_popup_position = p_position + _graph_edit.scroll_offset - Vector2(550, 100)
		_graph_popup.rect_position = p_position
		_graph_popup.show()


func _node_popup_request(p_position, node_name):
	_node_for_popup = node_name
	_node_popup.rect_position = p_position
	_node_popup.show()


func _graph_popup_index_pressed(index):
	var new_editor_node
	var new_graph_node
	match index:
		GraphPopupMenuItems.ADD_TEXT_NODE:
			new_editor_node = EditorTextNode.instance()
			new_graph_node = DialogueTextNode.new()
		GraphPopupMenuItems.ADD_BRANCH_NODE:
			new_editor_node = EditorBranchNode.instance()
			new_graph_node = BranchNode.new()
		GraphPopupMenuItems.ADD_CHOICE_NODE:
			new_editor_node = EditorChoiceNode.instance()
			new_graph_node = DialogueChoiceNode.new()
		GraphPopupMenuItems.ADD_SET_NODE:
			new_editor_node = EditorSetNode.instance()
			new_graph_node = VariableSetNode.new()
		GraphPopupMenuItems.ADD_ACTION_NODE:
			new_editor_node = EditorActionNode.instance()
			new_graph_node = ActionNode.new()
		GraphPopupMenuItems.ADD_SUB_GRAPH_NODE:
			new_editor_node = EditorSubGraphNode.instance()
			new_graph_node = SubGraph.new()
	new_graph_node.offset = _last_popup_position
	_graph_edit.add_child(new_editor_node)
	if _graph_edit.get_child_count() == 3: # TODO: magic number
		new_editor_node.is_root = true
	if new_editor_node.has_method("populate_characters"):
		new_editor_node.populate_characters(_characters)
	new_editor_node.configure_for_node(new_graph_node)
	_edited.graph.nodes.append(new_graph_node)
	if new_editor_node.is_root:
		_edited.graph.root_node = new_graph_node
	_connect_node_signals(new_editor_node)
	_set_dirty(true)


func _node_popup_index_pressed(index):
	match index:
		NodePopupMenuItems.SET_ROOT:
			_set_root(_node_for_popup)


func _set_root(node_name):
	for child in _graph_edit.get_children():
		if "is_root" in child:
			child.is_root = (child.name == node_name)
			if child.is_root:
				_edited.graph.root_node = child.node_resource
	_set_dirty(true)


func _removing_slot(slot, node_name):
	print ("Removal of slot " + String(slot) + " on node " + node_name + " requested")
	var connections = _graph_edit.get_connection_list()
	for connection in connections:
		if connection.from == node_name and connection.from_port == slot:
			# This one just gets removed
			_graph_edit.disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
		elif connection.from == node_name and connection.from_port > slot:
			# Remove and reconnect to slot + 1
			_graph_edit.disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
			_graph_edit.connect_node(connection.from, connection.from_port - 1, connection.to, connection.to_port)
	_set_dirty(true)


func _node_close_request(node_name):
	_confirmation_action = ConfirmationActions.REMOVE_NODE
	_node_to_remove = node_name
	_confirmation_dialog.dialog_text = "Are you sure you want to remove this node? This action cannot be undone."
	_confirmation_dialog.popup_centered()


func _action_confirmed():
	match _confirmation_action:
		ConfirmationActions.REMOVE_NODE:
			print ("Removal of node " + _node_to_remove + " confirmed.")
			var connections = _graph_edit.get_connection_list()
			for connection in connections:
				if connection.from == _node_to_remove or connection.to == _node_to_remove:
					# This one just gets removed
					_graph_edit.disconnect_node(connection.from, connection.from_port, connection.to, connection.to_port)
			var node = _graph_edit.get_node(_node_to_remove)
			_edited.graph.nodes.erase(node.node_resource)
			_graph_edit.remove_child(node)
			_set_dirty(true)
		ConfirmationActions.REMOVE_CHARACTER:
			_characters.remove(_character_to_remove)
			_update_character_list()
			_set_dirty(true)
		ConfirmationActions.CLOSE_GRAPH:
			_close_graph()


func _graph_selection_changed(index):
	_update_edited_graph()
	_edited = _open_graphs[index]
	_draw_edited_graph()


func _file_menu_index_pressed(index):
	match index:
		FileMenuItems.FILE_NEW:
			_on_new()
		FileMenuItems.FILE_OPEN:
			_on_open()
		FileMenuItems.FILE_SAVE:
			_on_save()
		FileMenuItems.FILE_SAVE_AS:
			_on_save_as()
		FileMenuItems.FILE_CLOSE:
			_on_close()


func _on_save():
	if _edited:
		if _edited.path != null:
			_perform_save()
		else:
			_get_resource_path()


func _on_open():
	_get_open_path()


func _sub_graph_selection_requested(node):
	_sub_graph_editor_node_for_assignment = node
	_get_sub_graph_open_path()


func _sub_graph_open_requested(graph, editor_node):
	edit_graph(graph, graph.resource_path)


func _on_close():
	if _edited:
		if _edited.dirty:
			_confirmation_dialog.dialog_text = "Unsaved changes will be lost. Are you sure you wish to continue?"
			_confirmation_action = ConfirmationActions.CLOSE_GRAPH
			_confirmation_dialog.popup_centered()
		else:
			_close_graph()


func _close_graph():
	_open_graphs.remove(_open_graphs.find(_edited))
	if _open_graphs.size() > 0:
		_edited = _open_graphs[0]
	else:
		_edited = null
	_update_file_list()
	_draw_edited_graph()


func _perform_save():
	_update_edited_graph()
	emit_signal("save_requested", _edited.graph, _edited.path)
	_set_dirty(false)


func _on_save_as():
	if _edited:
		_get_resource_path()


func _draw_edited_graph():
	print ("Drawing edited graph")

	# Clear the existing graph
	_clear_displayed_graph()

	if _edited:
		# Add the characters from the edited graph
		for character in _edited.graph.characters:
			_characters.append(character)
		_update_character_list()

		# Now create and configure the display nodes
		for node in _edited.graph.nodes:
			var editor_node
			if node is DialogueTextNode:
				editor_node = EditorTextNode.instance()
				editor_node.populate_characters(_characters)
			elif node is BranchNode:
				editor_node = EditorBranchNode.instance()
			elif node is VariableSetNode:
				editor_node = EditorSetNode.instance()
			elif node is DialogueChoiceNode:
				editor_node = EditorChoiceNode.instance()
			elif node is ActionNode:
				editor_node = EditorActionNode.instance()
				editor_node.populate_characters(_characters)
			elif node is SubGraph:
					editor_node = EditorSubGraphNode.instance()
			_graph_edit.add_child(editor_node)
			editor_node.configure_for_node(node)
			if node == _edited.graph.root_node:
				editor_node.is_root = true
			_connect_node_signals(editor_node)

		# Second pass to create connections
		for node in _edited.graph.nodes:
			if node.next != null:
				var from = _get_editor_node_for_graph_node(node)
				var to = _get_editor_node_for_graph_node(node.next)
				_graph_edit.connect_node(from.name, 0, to.name, 0)
			if node is DialogueChoiceNode or node is BranchNode:
				var from = _get_editor_node_for_graph_node(node)
				for index in range(0, node.branches.size()):
					if node.branches[index]:
						var to = _get_editor_node_for_graph_node(node.branches[index])
						_graph_edit.connect_node(from.name, index + 1, to.name, 0)


func _connect_node_signals(node):
	node.connect("removing_slot", self, "_removing_slot", [node.name])
	node.connect("close_request", self, "_node_close_request", [node.name])
	node.connect("popup_request", self, "_node_popup_request", [node.name])
	node.connect("offset_changed", self, "_node_offset_changed", [node.name])
	node.connect("modified", self, "_node_modified", [node.name])
	if node is EditorSubGraphNodeClass:
		node.connect("sub_graph_selection_requested", self, "_sub_graph_selection_requested", [node])
		node.connect("sub_graph_open_requested", self, "_sub_graph_open_requested", [node])


func _node_modified(node):
	_set_dirty(true)


func _node_offset_changed(node):
	_set_dirty(true)


func _set_dirty(val):
	_edited.dirty = val
	_update_file_list()


func _get_editor_node_for_graph_node(n):
	for node in _graph_edit.get_children():
		if node is EditorGraphNodeBaseClass:
			if node.node_resource == n:
				return node
	return null


func _get_graph_node_by_id(id):
	for node in _edited.graph.nodes:
		if node.get_rid() == id:
			return node
	return null


func _clear_displayed_graph():
	_graph_edit.clear_connections()
	var graph_nodes = _graph_edit.get_children()
	for node in graph_nodes:
		if node.name.match("Editor*"):
			_graph_edit.remove_child(node)
			node.queue_free()
	_characters.clear()


func _update_edited_graph():
	if _edited != null:
		#_edited.graph = CutsceneGraph.new()

		for character in _characters:
			if not character in _edited.graph.characters:
				_edited.graph.characters.append(character)
		for node in _graph_edit.get_children():
			# Watch out! Not all graph edit children are actually our nodes!
			if node.has_method("persist_changes_to_node"):
				node.persist_changes_to_node()
				# Clobber all relationships - they will be recreated if they still exist
				node.clear_node_relationships()
		var connections = _graph_edit.get_connection_list()
		for connection in connections:
			var from = _graph_edit.get_node(connection.from)
			var from_slot = connection.from_port
			var to = _graph_edit.get_node(connection.to)
			var to_slot = connection.to_port
			var from_dialogue_node = from.node_resource
			var to_dialogue_node = to.node_resource
			if from_dialogue_node is DialogueTextNode or from_dialogue_node is VariableSetNode or from_dialogue_node is ActionNode or from_dialogue_node is SubGraph:
				from_dialogue_node.next = to_dialogue_node
			elif from_dialogue_node is DialogueChoiceNode or from_dialogue_node is BranchNode:
				if from_slot == 0:
					from_dialogue_node.next = to_dialogue_node
				else:
					from_dialogue_node.branches[from_slot - 1] = to_dialogue_node


func _on_new():
	_update_edited_graph()
	_edited = OpenGraph.new()
	_edited.graph = CutsceneGraph.new()
	_edited.path = null
	_edited.dirty = true
	_open_graphs.append(_edited)
	_draw_edited_graph()
	_update_file_list()


func _update_file_list():
	_graph_list.clear()
	for graph in _open_graphs:
		_graph_list.add_item(graph.get_filename())
		if _edited.graph == graph.graph:
			_graph_list.select(_graph_list.get_item_count() - 1)
	_graph_list.ensure_current_is_visible()


func _update_character_list(selection = null):
	_character_list.clear()
	for character in _characters:
		_character_list.add_item(character.character_display_name)
		if character == selection:
			_character_list.select(_character_list.get_item_count() - 1)
	_character_list.ensure_current_is_visible()
	_update_node_characters()


func _update_node_characters():
	print ("Updating node characters")
	for node in _graph_edit.get_children():
		if node.has_method("populate_characters"):
			node.populate_characters(_characters)


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	print ("Connection request from " + from + ", " + String(from_slot) + " to " + to + ", " + String(to_slot))
	var connections = _graph_edit.get_connection_list()
	var allow = true
	for connection in connections:
		if connection.from == from and connection.from_port == from_slot:
			allow = false
			break
	if allow:
		_graph_edit.connect_node(from, from_slot, to, to_slot)
		_set_dirty(true)


func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	print ("Disconnection request from " + from + ", " + String(from_slot) + " to " + to + ", " + String(to_slot))
	_graph_edit.disconnect_node(from, from_slot, to, to_slot)
	_set_dirty(true)


func _on_AddCharacterButton_pressed():
	if _edited:
		_open_character_dialog.popup_centered_minsize(Vector2(800, 700))


func _on_RemoveCharacterButton_pressed():
	var selected = _character_list.get_selected_items()
	if selected.size() > 0:
		_character_to_remove = selected[0]
		_confirmation_action = ConfirmationActions.REMOVE_CHARACTER
		_confirmation_dialog.dialog_text = "Are you sure want to remove this character? Any nodes using it will switch to a different character."
		_confirmation_dialog.popup_centered()
