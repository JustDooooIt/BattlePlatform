class_name Piece extends Sprite2D

## 算子的面index
@onready var area2d: Area2D = get_node('Area2D')
@onready var plane_index: int = planes.get_health() - 1
@onready var faction: int = get_parent().get_index()

@export var planes: Parameters = null

var player: Player = null

signal my_piece_selected(piece: Piece)
signal other_piece_selected(piece: Piece)

func _enter_tree() -> void:
	connect('my_piece_selected', GameController._my_piece_selected)
	connect('other_piece_selected', GameController._other_piece_selected)
	
func _ready() -> void:
	area2d.input_event.connect(_input_event)
	GameController.pieces.add_piece(get_map_position(), self)
	texture = get_paramter().texture
	player = get_parent()

func _input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_mask == MOUSE_BUTTON_MASK_LEFT:
			if faction == 0:
				emit_signal('my_piece_selected', self)
			else:
				emit_signal('other_piece_selected', self)
			get_viewport().set_input_as_handled()

func get_paramter() -> Parameter:
	return planes.get_param(plane_index)

func get_map_position() -> Vector2i:
	return %HexMap.local_to_map(%HexMap.to_local(position))

func get_terrain(position: Vector2i) -> int:
	var maps: Array = %HexMap.get_children()
	for map: TileMapLayer in maps:
		var tile = map.get_cell_tile_data(position)
		if tile != null:
			return map.get_index()
	return -1
