class_name CellStack extends RefCounted

var dict: Dictionary = {}

func get_cell_pieces(position: Vector2i) -> Array:
	if dict.has(position):
		return dict[position]
	else:
		return []

func add_piece(position: Vector2i, piece: Piece):
	if dict.has(position):
		dict[position].append(piece)
	else:
		dict[position] = [piece]

func get_cell_size(position: Vector2i) -> int:
	if dict.has(position):
		return dict[position].size()
	else:
		return 0
		
func cell_type(position: Vector2i, allies_type: int):
	var type: int = 0
	if dict.has(position):
		var pieces: Array = dict[position] as Array;
		if pieces.is_empty():
			return CellType.EMPTY
		if pieces.all(func(e): return e.faction == allies_type):
			return CellType.ALLIES
		elif pieces.all(func(e): return e.faction != allies_type):
			return CellType.ENEMY
		else:
			return CellType.MIXED
	else:
		return CellType.EMPTY

enum CellType {
	EMPTY, ALLIES, ENEMY, MIXED
}
