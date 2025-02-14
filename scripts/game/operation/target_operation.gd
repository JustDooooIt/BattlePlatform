class_name TargetOperation extends Operation

var start: Vector2i
var target: Vector2i

func _init(piece: Piece, start: Vector2i, target: Vector2i) -> void:
	super._init(piece)
	self.start = start
	self.target = target
