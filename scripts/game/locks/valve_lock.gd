class_name ValveLock extends RefCounted

var unlock_func: Callable = Callable()

func _condition(valve_context: ValveContext) -> bool:
	return true

func _unlock(valve_context: ValveContext, unlock_func: Callable) -> void:
	return

func wait_unlock(valve_context: ValveContext) -> void:
	if _condition(valve_context):
		if unlock_func.is_valid():
			unlock_func.call(valve_context)
	else:
		_unlock(valve_context, unlock_func)
