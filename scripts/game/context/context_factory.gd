class_name ContextFactory extends RefCounted

static func create(type: int, piece: Piece, start: Vector2i = Vector2i(), target: Vector2i = Vector2i()) -> ValveContext:
	var context: ValveContext = null
	match type:
		MOVE:
			var move_context: MoveContext = MoveContext.new()
			var param = piece.get_paramter();
			move_context.movement = param.movement
			move_context.start = start
			move_context.target = target
			move_context.piece = piece
			move_context.state = piece.state
			context = move_context
		ATTACK:
			var attack_context: AttackContext = AttackContext.new()
			attack_context.start = start
			attack_context.target = target
			attack_context.piece = piece
			attack_context.state = piece.state
			context = attack_context
		_:
			assert(false, 'Type error')
	return context


enum {
	MOVE, ATTACK
}
