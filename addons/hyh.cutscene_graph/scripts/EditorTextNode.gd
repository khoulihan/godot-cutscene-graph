tool
extends "EditorGraphNodeBase.gd"


var _characters


func _get_text_edit():
	return get_node("RootContainer/VerticalLayout/TextEdit")


func _get_character_select():
	return get_node("RootContainer/VerticalLayout/OptionsContainer/CharacterSelect")


func _get_variant_select():
	return get_node("RootContainer/VerticalLayout/OptionsContainer/VariantSelect")


func _get_translation_key_edit():
	return get_node("RootContainer/VerticalLayout/TranslationContainer/TranslationKeyEdit")


func configure_for_node(n):
	.configure_for_node(n)
	set_text(n.text)
	set_translation_key(n.text_translation_key)
	select_character(n.character)
	select_variant(n.character_variant)


func persist_changes_to_node():
	print("Persisting changes")
	.persist_changes_to_node()
	node_resource.text = get_text()
	node_resource.text_translation_key = get_translation_key()
	var selected_c = get_selected_character()
	if selected_c != -1:
		node_resource.character = _characters[selected_c]
		var selected_v = get_selected_variant()
		if selected_v != -1:
			node_resource.character_variant = node_resource.character.character_variants[selected_v]
	else:
		node_resource.character = null


func get_text():
	return _get_text_edit().text


func set_text(speech):
	_get_text_edit().text = speech


# Don't think I want to store the text as an array anymore
func get_text_array():
	var t = _get_text_edit().text
	return t.split("\n")


func set_text_from_array(speech):
	# This requires that speech be a PoolStringArray. If that is not the case, should convert here
	_get_text_edit().text = speech.join("\n")


func get_selected_character():
	return _get_character_select().selected


func get_selected_variant():
	return _get_variant_select().selected


func set_translation_key(k):
	_get_translation_key_edit().text = k


func get_translation_key():
	return _get_translation_key_edit().text


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


func select_variant(mood):
	var character_select = _get_character_select()
	var variant_select = _get_variant_select()
	# This will be used when displaying a graph initially.
	var variants = _characters[character_select.selected].character_variants
	if variants:
		for index in range(0, variants.size()):
			var v = variants[index]
			if v == mood:
				variant_select.select(index)


func _on_CharacterSelect_item_selected(ID):
	var character = _characters[ID]
	_populate_variants(character.character_variants)
	emit_signal("modified")

func on_close_request():
	.on_close_request()


func _on_gui_input(ev):
	._on_gui_input(ev)


func _on_VariantSelect_item_selected(ID):
	emit_signal("modified")


func _on_TextEdit_text_changed():
	emit_signal("modified")
