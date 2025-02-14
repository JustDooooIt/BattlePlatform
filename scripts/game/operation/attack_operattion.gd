class_name AttackOperation extends TargetOperation

var attack_info: AttackInfo = null

func _init(attack_info: AttackInfo, piece: Piece, start: Vector2i, enemyies: Array, target: Vector2i) -> void:
	super._init(piece, start, target)
	self.attack_info = attack_info
	attack_info.attackers.add_piece(target, piece)
	for enemy in enemyies:
		attack_info.defensers.add_piece(start, enemy)

func _run():
	var valve: Valve = AttackValve.new(piece, start, target)
	var pipeline: Pipeline = piece.pipeline
	pipeline.add_valve(valve)
