extends Resource

export (String) var character_name
export (String) var character_display_name
export (Array, Resource) var character_variants

var _character_variants

func get_character_variants():
	if _character_variants == null:
		_character_variants = {}
		for v in character_variants:
			_character_variants[v.variant_name] = v
	return _character_variants
