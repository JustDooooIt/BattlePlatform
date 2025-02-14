class_name MoveOperation extends TargetOperation

func _init(piece: Piece, start: Vector2i, target: Vector2i) -> void:
	super._init(piece, start, target)

func _run():
	var valve: Valve = MoveValve.new(piece, start, target)
	var pipeline = piece.pipeline
	pipeline.add_valve(valve)
