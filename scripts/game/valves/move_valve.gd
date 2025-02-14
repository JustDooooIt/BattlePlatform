class_name MoveValve extends Valve

var target: Vector2i
var start: Vector2i

func _init(piece: Piece, start: Vector2i, target: Vector2i) -> void:
	super._init(piece, false)
	self.target = target
	self.start = start

func _create_context() -> MoveContext:
	return ContextFactory.create(ContextType.MOVE, piece, piece.get_map_position(), target)

func _run(context: ValveContext):
	var move_context = context as MoveContext
	var position = get_node("/root/Game/HexMap").m_map_to_local(move_context.target)
	context.piece.position = position
	var comment = Discussion.BattleComment.new()
	comment.faction = GameController.faction
	comment.piece_id = int(String(piece.name))
	comment.target = move_context.target
	comment.username = GameController.github_username
	var dict = Discussion.class_to_dict(comment)
	var callable = Discussion.create_comment.bind(GameController.discussion_id, JSON.stringify(dict))
	Discussion.enqueue(callable)
