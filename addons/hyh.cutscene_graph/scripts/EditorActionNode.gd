tool
extends "EditorGraphNodeBase.gd"

onready var _action_name = get_node("RootContainer/GridContainer/ActionNameEdit")
onready var _character_select = get_node("RootContainer/GridContainer/CharacterSelect")
onready var _variant_select = get_node("RootContainer/GridContainer/VariantSelect")
onready var _argument = get_node("RootContainer/GridContainer/ArgumentEdit")

var _characters


func _get_character_select():
	return get_node("RootContainer/GridContainer/CharacterSelect")


func _get_variant_select():
	return get_node("RootContainer/GridContainer/VariantSelect")


func _get_argument_edit():
	return get_node("RootContainer/GridContainer/ArgumentEdit")


func _get_action_name_edit():
	return get_node("RootContainer/GridContainer/ActionNameEdit")


func configure_for_node(n):
	.configure_for_node(n)
	set_action_name(n.action_name)
	set_argument(n.argument)
	select_character(n.character)
	select_variant(n.character_variant)


func persist_changes_to_node():
	.persist_changes_to_node()
	node_resource.action_name = get_action_name()
	node_resource.argument = get_argument()
	var selected_c = get_selected_character()
	if selected_c != -1:
		node_resource.character = _characters[selected_c]
		var selected_v = get_selected_variant()
		if selected_v != -1:
			node_resource.character_variant = node_resource.character.character_variants[selected_v]
	else:
		node_resource.character = null


func get_action_name():
	return _get_action_name_edit().text


func set_action_name(speech):
	_get_action_name_edit().text = speech


func get_argument():
	return _get_argument_edit().text


func set_argument(speech):
	_get_argument_edit().text = speech


func get_selected_character():
	return _get_character_select().selected


func get_selected_variant():
	return _get_variant_select().selected


func populate_characters(characters):
	print ("Populating character select")
	var character_select = _get_character_select()
	_characters = characters
	var selected = character_select.selected
	character_select.clear()
	for character in characters:
		character_select.add_item(character.character_display_name)
	# TODO: What happens here if previously selected index is out of range?
	# Should determine name of selection beforehand and be sure to reselect that character, or null
	# selection if gone
	character_select.select(selected)
	if character_select.selected != -1:
		_populate_variants(_characters[character_select.selected].character_variants)


func select_character(character):
	# This will be used when displaying a graph initially.
	var character_select = _get_character_select()
	for index in range(0, _characters.size()):
		var c = _characters[index]
		if c == character:
			character_select.select(index)
			_populate_variants(_characters[index].character_variants)


func _populate_variants(variants):
	var variant_select = _get_variant_select()
	var selected = variant_select.selected
	variant_select.clear()
	if variants:
		for v in variants:
			variant_select.add_item(v.variant_display_name)
		variant_select.select(selected)


func select_variant(v):
	# This will be used when displaying a graph initially.
	var character_select = _get_character_select()
	var variants = _characters[character_select.selected].character_variants
	if variants:
		for index in range(0, variants.size()):
			var cv = variants[index]
			if cv == v:
				_variant_select.select(index)


func _on_gui_input(ev):
	._on_gui_input(ev)


func _on_CharacterSelect_item_selected(ID):
	var character = _characters[ID]
	_populate_variants(character.character_variants)
	emit_signal("modified")


func _on_VariantSelect_item_selected(ID):
	emit_signal("modified")
