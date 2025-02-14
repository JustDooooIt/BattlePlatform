## 算子
class_name PlayerPiece extends Piece

@onready var pipeline: Pipeline = $".."
@onready var enemy: Network = $"../../1"

var state: Dictionary = {}
var game_state: GameState = GameState.MOVE
	
func _ready() -> void:
	super._ready()
	init_state()

func can_move(target: Vector2i) -> bool:
	var cell_type: int = GameController.pieces.cell_type(target, 0)
	return self.faction == 0 and \
			game_state == GameState.MOVE and \
			pipeline.state == Player.State.PLAYING and \
			(cell_type == CellStack.CellType.EMPTY or cell_type == CellStack.CellType.ALLIES)

func can_attack(target: Vector2i) -> bool:
	var cell_type: int = GameController.pieces.cell_type(target, 0)
	return self.faction == 0 and \
			game_state == GameState.MOVE and \
			pipeline.state == Player.State.PLAYING and \
			cell_type == CellStack.CellType.ENEMY

func can_advance(target: Vector2i) -> bool:
	var cell_type: int = GameController.pieces.cell_type(target, 0)
	return self.faction == 0 and \
			game_state == GameState.ADVANCE and \
			pipeline.state == Player.State.PLAYING and \
			(cell_type == CellStack.CellType.EMPTY or cell_type == CellStack.CellType.ALLIES)

func can_fallback(target: Vector2i):
	var cell_type: int = GameController.pieces.cell_type(target, 0)
	return self.faction == 0 and \
			game_state == GameState.FALLBACK and \
			pipeline.state == Player.State.PLAYING and \
			(cell_type == CellStack.CellType.EMPTY or cell_type == CellStack.CellType.ALLIES)

func init_state():
	var param: Parameter = get_paramter()
	var prop_list: Array[Dictionary] = param.get_property_list()
	for prop: Dictionary in prop_list:
		if prop['usage'] & PROPERTY_USAGE_SCRIPT_VARIABLE:
			state[prop['name']] = param.get(prop['name'])

enum GameState{
	MOVE, ATTACK, ADVANCE, FALLBACK
}
