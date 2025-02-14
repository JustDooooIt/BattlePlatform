class_name AttackInfo extends RefCounted

var attackers: CellStack = CellStack.new()
var defensers: CellStack = CellStack.new()
var advance_target: Stack = Stack.new()

func get_attacker(position: Vector2i) -> Array[Piece]:
	return attackers.get_cell_pieces(position)

func get_defenser(position: Vector2i) -> Array[Piece]:
	return defensers.get_cell_pieces(position)
