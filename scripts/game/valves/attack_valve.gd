class_name AttackValve extends Valve

var target: Vector2i
var start: Vector2i

func _init(piece: Piece, start: Vector2i, target: Vector2i) -> void:
	super._init(piece, true)
	self.target = target
	self.start = start
	self.lock = BattleLock.new()
	
func _create_context() -> AttackContext:
	return ContextFactory.create(ContextFactory.ATTACK, piece, piece.get_map_position(), target)

func _run(context: ValveContext) -> void:
	BattleController.commit(context as AttackContext)
