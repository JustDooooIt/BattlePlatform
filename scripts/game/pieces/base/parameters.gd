class_name Parameters extends Resource

@export var param_arr: Array[Parameter] = []

func get_param(id: int) -> Parameter:
	return param_arr[id]

func get_health() -> int:
	return param_arr.size()
