extends Camera2D

var velocity: float = 20
var dragged:bool = false
var mouse_left_pressed: bool = false
var mouse_mid_pressed: bool = false

func _process(delta: float) -> void:
	var mouse_position = get_viewport().get_mouse_position()
	var screen_center = Vector2(get_viewport().size / 2)
	var mouse_offset = (mouse_position - screen_center) / Vector2(get_viewport().size)

func _unhandled_input(event: InputEvent) -> void:
	map_drag(event)
	map_zoom(event)

func map_drag(event) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			mouse_left_pressed = true
		else:
			mouse_left_pressed = false
	elif event is InputEventMouseMotion:
		if mouse_left_pressed:
			position -= event.screen_relative

func map_zoom(event: InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.25
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom /= 1.25
