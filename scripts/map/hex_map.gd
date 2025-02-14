extends TileMapLayer

signal cell_right_clicked(position: Vector2)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_mask == MOUSE_BUTTON_MASK_RIGHT:
			emit_signal("cell_right_clicked", Vector2i(local_to_map(get_local_mouse_position())))

func _ready() -> void:
	connect('cell_right_clicked', GameController._cell_right_clicked)

func m_local_to_map(position: Vector2) -> Vector2i:
	return (local_to_map(position)) 

func m_map_to_local(position: Vector2i) -> Vector2:
	return self.position + map_to_local(position)
