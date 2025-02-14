class_name Stack extends RefCounted

var dict: Dictionary = {}

func add(key, value):
	if dict.has(key):
		dict[key].append(value)
	else:
		dict[key] = [value]

func size(key) -> Array:
	if dict.has(key):
		return (dict[key] as Array)
	else:
		return []
